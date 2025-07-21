// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title ColdstartPaymentSplitter
 * @dev Handles automatic revenue distribution for coldstart editions
 */
contract ColdstartPaymentSplitter is ReentrancyGuard {
    event PaymentReceived(address from, uint256 amount);
    event PaymentSplit(address artist, uint256 artistAmount, address producer, uint256 producerAmount, address operator, uint256 operatorAmount);

    address public immutable artist;
    address public immutable productionPartner;
    address public immutable operator;
    uint256 public immutable artistShare;      // in basis points (7500 = 75%)
    uint256 public immutable productionShare;  // in basis points (2300 = 23%)
    uint256 public immutable operatorShare;    // in basis points (200 = 2%)
    
    uint256 public totalReceived;
    uint256 public totalSplit;

    constructor(
        address _artist,
        address _productionPartner,
        address _operator,
        uint256 _artistShare,
        uint256 _productionShare,
        uint256 _operatorShare
    ) {
        require(_artist != address(0), "Invalid artist address");
        require(_productionPartner != address(0), "Invalid production partner address");
        require(_operator != address(0), "Invalid operator address");
        require(_artistShare + _productionShare + _operatorShare == 10000, "Shares must total 100%");

        artist = _artist;
        productionPartner = _productionPartner;
        operator = _operator;
        artistShare = _artistShare;
        productionShare = _productionShare;
        operatorShare = _operatorShare;
    }

    /**
     * @dev Receive payment and automatically split to all parties
     */
    receive() external payable {
        require(msg.value > 0, "No payment received");
        
        totalReceived += msg.value;
        
        uint256 artistAmount = (msg.value * artistShare) / 10000;
        uint256 productionAmount = (msg.value * productionShare) / 10000;
        uint256 operatorAmount = msg.value - artistAmount - productionAmount; // Handle rounding

        // Transfer to all parties
        Address.sendValue(payable(artist), artistAmount);
        Address.sendValue(payable(productionPartner), productionAmount);
        Address.sendValue(payable(operator), operatorAmount);

        totalSplit += msg.value;

        emit PaymentReceived(msg.sender, msg.value);
        emit PaymentSplit(artist, artistAmount, productionPartner, productionAmount, operator, operatorAmount);
    }

    /**
     * @dev Get split information
     */
    function getSplitInfo() external view returns (
        address _artist,
        address _productionPartner,
        address _operator,
        uint256 _artistShare,
        uint256 _productionShare,
        uint256 _operatorShare
    ) {
        return (artist, productionPartner, operator, artistShare, productionShare, operatorShare);
    }
}

/**
 * @title ColdstartEditionNFT
 * @dev Enhanced NFT contract with integrated payment splitting and direct purchase
 */
contract ColdstartEditionNFT is ERC721, Ownable, ReentrancyGuard {
    struct Edition {
        uint256 editionID;
        uint256 parentEditionID;
        address operator;
        address artist;
        address productionPartner;
        uint256 salePrice; // in wei
        uint256 editionSize;
        uint256 minted;
        uint256 productionCost; // in wei
        uint256 artistShare;              // in basis points (7500 = 75%)
        uint256 productionPartnerShare;   // in basis points (2300 = 23%)
        uint256 operatorShare;            // in basis points (200 = 2%)
        string artworkURI;
        address paymentSplitter;          // Address of payment splitter contract
        bool directSaleEnabled;           // Whether direct purchase is enabled
    }

    uint256 public nextEditionID;
    uint256 public nextTokenID;

    mapping(uint256 => Edition) public editions;
    mapping(uint256 => uint256) public tokenToEdition;
    mapping(uint256 => mapping(uint256 => bool)) public editionTokenExists; // editionID => tokenNumber => exists

    event EditionCreated(uint256 indexed editionID, address indexed artist, address indexed productionPartner, address paymentSplitter);
    event EditionMinted(uint256 indexed tokenID, uint256 indexed editionID, address indexed to, uint256 editionNumber);
    event DirectPurchase(uint256 indexed editionID, address indexed buyer, uint256 tokenID, uint256 amount);

    constructor(address initialOwner)
        ERC721("Coldstart Protocol", "COLD")
        Ownable(initialOwner)
    {}

    /**
     * @dev Create a new edition with automatic payment splitter deployment
     */
    function createEdition(
        uint256 parentEditionID,
        address operator,
        address artist,
        address productionPartner,
        uint256 salePrice,
        uint256 editionSize,
        uint256 productionCost,
        uint256 artistShare,
        uint256 productionPartnerShare,
        uint256 operatorShare,
        string memory artworkURI,
        bool enableDirectSale
    ) public onlyOwner returns (uint256, address) {
        require(
            artistShare + productionPartnerShare + operatorShare == 10000,
            "Shares must add up to 100%"
        );
        require(editionSize > 0, "Edition size must be greater than 0");

        // Deploy payment splitter contract
        ColdstartPaymentSplitter splitter = new ColdstartPaymentSplitter(
            artist,
            productionPartner,
            operator,
            artistShare,
            productionPartnerShare,
            operatorShare
        );

        editions[nextEditionID] = Edition({
            editionID: nextEditionID,
            parentEditionID: parentEditionID,
            operator: operator,
            artist: artist,
            productionPartner: productionPartner,
            salePrice: salePrice,
            editionSize: editionSize,
            minted: 0,
            productionCost: productionCost,
            artistShare: artistShare,
            productionPartnerShare: productionPartnerShare,
            operatorShare: operatorShare,
            artworkURI: artworkURI,
            paymentSplitter: address(splitter),
            directSaleEnabled: enableDirectSale
        });

        emit EditionCreated(nextEditionID, artist, productionPartner, address(splitter));
        
        uint256 editionID = nextEditionID;
        nextEditionID++;
        
        return (editionID, address(splitter));
    }

    /**
     * @dev Purchase an edition directly (if enabled) - payment automatically split
     */
    function purchaseEdition(uint256 editionID) public payable nonReentrant {
        Edition storage ed = editions[editionID];
        require(ed.directSaleEnabled, "Direct sale not enabled for this edition");
        require(ed.minted < ed.editionSize, "Edition sold out");
        require(msg.value >= ed.salePrice, "Insufficient payment");

        // Forward payment to splitter (automatically distributes)
        Address.sendValue(payable(ed.paymentSplitter), msg.value);

        // Mint NFT to buyer
        uint256 tokenID = nextTokenID;
        uint256 editionNumber = ed.minted + 1;
        
        _mint(msg.sender, tokenID);
        tokenToEdition[tokenID] = editionID;
        editionTokenExists[editionID][editionNumber] = true;
        ed.minted++;
        nextTokenID++;

        emit EditionMinted(tokenID, editionID, msg.sender, editionNumber);
        emit DirectPurchase(editionID, msg.sender, tokenID, msg.value);
    }

    /**
     * @dev Admin mint (for external payment processing)
     */
    function mintFromEdition(uint256 editionID, address to) public onlyOwner {
        Edition storage ed = editions[editionID];
        require(ed.minted < ed.editionSize, "Edition sold out");
        
        uint256 tokenID = nextTokenID;
        uint256 editionNumber = ed.minted + 1;
        
        _mint(to, tokenID);
        tokenToEdition[tokenID] = editionID;
        editionTokenExists[editionID][editionNumber] = true;
        ed.minted++;
        nextTokenID++;

        emit EditionMinted(tokenID, editionID, to, editionNumber);
    }

    /**
     * @dev Batch mint multiple tokens from an edition
     */
    function batchMintFromEdition(uint256 editionID, address[] calldata recipients) external onlyOwner {
        Edition storage ed = editions[editionID];
        require(ed.minted + recipients.length <= ed.editionSize, "Would exceed edition size");

        for (uint256 i = 0; i < recipients.length; i++) {
            mintFromEdition(editionID, recipients[i]);
        }
    }

    /**
     * @dev Get edition information
     */
    function getEdition(uint256 editionID) external view returns (Edition memory) {
        return editions[editionID];
    }

    /**
     * @dev Get edition info for a token
     */
    function editionOf(uint256 tokenID) public view returns (Edition memory) {
        return editions[tokenToEdition[tokenID]];
    }

    /**
     * @dev Check if a specific edition number has been minted
     */
    function isEditionNumberMinted(uint256 editionID, uint256 editionNumber) external view returns (bool) {
        return editionTokenExists[editionID][editionNumber];
    }

    /**
     * @dev Get available edition numbers for purchase
     */
    function getAvailableEditions(uint256 editionID) external view returns (uint256[] memory) {
        Edition memory ed = editions[editionID];
        uint256 available = ed.editionSize - ed.minted;
        uint256[] memory availableNumbers = new uint256[](available);
        
        uint256 index = 0;
        for (uint256 i = 1; i <= ed.editionSize; i++) {
            if (!editionTokenExists[editionID][i]) {
                availableNumbers[index] = i;
                index++;
            }
        }
        
        return availableNumbers;
    }

    /**
     * @dev Set artwork URI for an edition
     */
    function setArtworkURI(uint256 editionID, string memory newURI) public onlyOwner {
        editions[editionID].artworkURI = newURI;
    }

    /**
     * @dev Enable/disable direct sales for an edition
     */
    function setDirectSaleEnabled(uint256 editionID, bool enabled) public onlyOwner {
        editions[editionID].directSaleEnabled = enabled;
    }

    /**
     * @dev Update sale price for an edition
     */
    function setSalePrice(uint256 editionID, uint256 newPrice) public onlyOwner {
        editions[editionID].salePrice = newPrice;
    }

    /**
     * @dev Get total number of editions created
     */
    function getTotalEditions() external view returns (uint256) {
        return nextEditionID;
    }

    /**
     * @dev Override tokenURI to use edition artwork URI
     */
    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        require(_ownerOf(tokenID) != address(0), "Token does not exist");
        return editions[tokenToEdition[tokenID]].artworkURI;
    }

    /**
     * @dev Emergency withdrawal (only for stuck funds, not normal operation)
     */
    function emergencyWithdraw() external onlyOwner {
        Address.sendValue(payable(owner()), address(this).balance);
    }
}

/**
 * @title ColdstartFactory
 * @dev Factory contract for deploying new coldstart cycles
 */
contract ColdstartFactory is Ownable {
    event ColdstartCycleDeployed(address indexed nftContract, address indexed deployer, string name);

    struct CycleInfo {
        address nftContract;
        address deployer;
        string name;
        uint256 deployedAt;
    }

    CycleInfo[] public cycles;
    mapping(address => bool) public isValidColdstartContract;

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Deploy a new coldstart cycle
     */
    function deployColdstartCycle(string memory cycleName) external returns (address) {
        ColdstartEditionNFT newContract = new ColdstartEditionNFT(msg.sender);
        
        cycles.push(CycleInfo({
            nftContract: address(newContract),
            deployer: msg.sender,
            name: cycleName,
            deployedAt: block.timestamp
        }));

        isValidColdstartContract[address(newContract)] = true;

        emit ColdstartCycleDeployed(address(newContract), msg.sender, cycleName);
        
        return address(newContract);
    }

    /**
     * @dev Get total number of deployed cycles
     */
    function getTotalCycles() external view returns (uint256) {
        return cycles.length;
    }

    /**
     * @dev Get cycle information
     */
    function getCycle(uint256 index) external view returns (CycleInfo memory) {
        require(index < cycles.length, "Cycle does not exist");
        return cycles[index];
    }

    /**
     * @dev Get all cycles by a deployer
     */
    function getCyclesByDeployer(address deployer) external view returns (CycleInfo[] memory) {
        uint256 count = 0;
        
        // Count cycles by deployer
        for (uint256 i = 0; i < cycles.length; i++) {
            if (cycles[i].deployer == deployer) {
                count++;
            }
        }

        // Create array of correct size
        CycleInfo[] memory deployerCycles = new CycleInfo[](count);
        uint256 index = 0;

        // Fill array
        for (uint256 i = 0; i < cycles.length; i++) {
            if (cycles[i].deployer == deployer) {
                deployerCycles[index] = cycles[i];
                index++;
            }
        }

        return deployerCycles;
    }
}