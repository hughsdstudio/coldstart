// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ArtistEditionNFT
 * @dev ERC721 NFT with multi-party edition registry (artist, production partner, operator) and revenue share data.
 *      Minting and edition creation are admin-only. Revenue split is stored but not enforced in payable logic.
 *      Intended for external UI and off-chain or future on-chain revenue distribution.
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtistEditionNFT is ERC721, Ownable {
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
        uint256 artistShare;              // in basis points (10000 = 100%)
        uint256 productionPartnerShare;   // in basis points
        uint256 operatorShare;            // in basis points
        string artworkURI;
    }

    uint256 public nextEditionID;
    uint256 public nextTokenID;

    mapping(uint256 => Edition) public editions;
    mapping(uint256 => uint256) public tokenToEdition;

    // Events for off-chain indexers/UI
    event EditionCreated(uint256 indexed editionID, address indexed artist, address indexed productionPartner);
    event EditionMinted(uint256 indexed tokenID, uint256 indexed editionID, address indexed to);

    constructor(address initialOwner)
        ERC721("ArtistEditionNFT", "AENFT")
        Ownable(initialOwner)
    {}

    /**
     * @dev Create a new edition. Only owner (admin) can call.
     * @param parentEditionID ID of parent edition, if any (0 for none)
     * @param operator Address of operator/ops wallet
     * @param artist Address of artist
     * @param productionPartner Address of production/fabrication partner
     * @param salePrice Sale price per NFT (in wei)
     * @param editionSize Total number of tokens in edition
     * @param productionCost Cost to produce edition (in wei)
     * @param artistShare Artist's share in basis points (e.g. 3400 = 34%)
     * @param productionPartnerShare Fabricator's share (basis points)
     * @param operatorShare Operator's share (basis points)
     * @param artworkURI Metadata URI (IPFS or URL)
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
        string memory artworkURI
    ) public onlyOwner returns (uint256) {
        require(
            artistShare + productionPartnerShare + operatorShare == 10000,
            "Shares must add up to 100%"
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
            artworkURI: artworkURI
        });
        emit EditionCreated(nextEditionID, artist, productionPartner);
        nextEditionID++;
        return nextEditionID - 1;
    }

    /**
     * @dev Mint a token from a given edition to `to`. Only owner (admin) can call.
     * @param editionID The edition to mint from
     * @param to The address to receive the NFT
     */
    function mintFromEdition(uint256 editionID, address to) public onlyOwner {
        Edition storage ed = editions[editionID];
        require(ed.minted < ed.editionSize, "Edition sold out");
        uint256 tokenID = nextTokenID;
        _mint(to, tokenID);
        tokenToEdition[tokenID] = editionID;
        ed.minted++;
        emit EditionMinted(tokenID, editionID, to);
        nextTokenID++;
    }

    /**
     * @dev Return the Edition info for a tokenID
     */
    function editionOf(uint256 tokenID) public view returns (Edition memory) {
        return editions[tokenToEdition[tokenID]];
    }

    /**
     * @dev Set the artwork URI for an edition (admin-only)
     */
    function setArtworkURI(uint256 editionID, string memory newURI) public onlyOwner {
        editions[editionID].artworkURI = newURI;
    }
}
