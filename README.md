# coldstart
**A Protocol for Open Source Modeling, Cooperative Production, and Para-Market Circulation**

coldstart is a minimal, recursive protocol for the collective production and distribution of artworks outside of traditional market infrastructures. It operates as a para-institutional structure—not a gallery, not a marketplace, and not a brand, but something that runs alongside and against these ossified models. It provides a clear, forkable toolkit for organizing creative labor, coordinating production, and enacting distribution through transparent, automated smart contracts.

Rather than replacing the traditional art market, coldstart seeks to model a parallel infrastructure—one oriented around collaborative authorship, equitable fabrication, and versioned evolution over time. It draws on the logic of open-source software and DAO governance, but retools those forms toward the epistemic and aesthetic work of cultural production.

## What It Does
* **Automated revenue distribution** through smart contracts that instantly split payments to artists, producers, and operators
* **Hybrid payment infrastructure** supporting both cryptocurrency and traditional credit card purchases
* **Trustless transaction processing** that eliminates centralized payment collection and redistribution
* **Edition-based NFT minting** with real-time availability tracking and transparent on-chain metadata
* **Factory deployment system** enabling anyone to fork and deploy their own coldstart cycles
* **GitHub-based versioning** to document and evolve the protocol with each iteration
* **Public-facing web storefront** with integrated wallet connection and purchase interface

## Who It's For
coldstart is designed for artists, designers, and theorists who are:
* Interested in building collective infrastructure for production and distribution
* Operating outside (or in critical relation to) traditional galleries and markets
* Eager to engage with Web3 tooling including smart contracts, wallet integration, and decentralized systems
* Committed to modeling alternatives, rather than merely critiquing dominant systems
* Seeking transparent, automated revenue sharing without centralized intermediaries

## How It Works
1. **Deploy cycle infrastructure** using the ColdstartFactory contract
2. **Create editions** with embedded payment splitter contracts for automatic revenue distribution
3. **Contributors submit work** with wallet addresses and revenue split preferences (default: 75% artist, 23% producer, 2% operations)
4. **Smart contracts handle all transactions** - payments instantly distributed to all parties upon purchase
5. **Buyers purchase directly** via cryptocurrency or credit card through integrated payment processing
6. **NFTs automatically mint** to buyers while funds simultaneously distribute to contributors
7. **Cohort reconvenes** to evaluate and iterate the protocol, publishing updates via GitHub

coldstart is not fixed. It is designed to mutate.

## Technology Stack

### Smart Contracts (Ethereum)
* **ColdstartEditionNFT**: ERC721-based contract with integrated payment splitting and direct purchase capabilities
* **ColdstartPaymentSplitter**: Automatic revenue distribution contract deployed per edition
* **ColdstartFactory**: Permissionless deployment system for creating new cycles
* **Multi-modal minting**: Supports both direct crypto purchases and admin-minted NFTs for credit card payments
* **Real-time edition tracking**: On-chain availability status for frontend integration

### Frontend Infrastructure
* **React-based UI** with Web3 wallet integration (MetaMask, WalletConnect)
* **Smart contract interaction** for edition creation, purchasing, and management
* **Payment processor integration** supporting both crypto and fiat payments
* **Real-time edition availability** with visual purchase interface
* **Responsive design** optimized for both desktop and mobile interaction

### Payment Architecture
* **Trustless revenue splitting** with payments instantly distributed upon purchase
* **Hybrid payment support**: Direct crypto payments and credit card processing via webhooks
* **No custodial period**: Funds never held by intermediaries or central authorities
* **Transparent on-chain splits**: All revenue distribution logic publicly auditable

## Repository Contents
* Smart contract system (`ColdstartProtocol.sol`)
* React-based web interface with wallet integration
* Factory deployment scripts and documentation
* Protocol iteration framework and governance documentation
* Edition creation templates and submission guidelines
* Technical integration guides for payment processors

## Deployment & Forking
The factory contract enables permissionless deployment of new coldstart cycles. Anyone can:
* Deploy their own edition contract with custom parameters
* Modify smart contract logic for specialized use cases
* Fork the entire protocol for different artistic communities
* Integrate with alternative payment systems or blockchains

## License
coldstart is released under an **MIT License**. All contributors are encouraged to fork, adapt, extend, and redeploy the protocol according to their community's needs.
