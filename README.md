##coldstart

A Protocol for Open Source Modeling, Cooperative Production, and Para-Market Circulation

coldstart is a minimal, recursive protocol for the collective production and distribution of artworks outside of traditional market infrastructures. It operates as a para-institutional structure—not a gallery, not a marketplace, and not a brand, but something that runs alongside and against these ossified models. It provides a clear, forkable toolkit for organizing creative labor, coordinating production, and enacting distribution through transparent, on-chain contracts.

Rather than replacing the traditional art market, coldstart seeks to model a parallel infrastructure—one oriented around collaborative authorship, equitable fabrication, and versioned evolution over time. It draws on the logic of open-source software and DAO governance, but retools those forms toward the epistemic and aesthetic work of cultural production.

What It Does

coldstart provides:

A shared framework for submission, production, and distribution of editioned works
A smart contract that automates payments, royalties, and removes the need for centralized administration
A GitHub-based versioning system that documents and evolves the protocol with each cycle
A public-facing web storefront (React UI) for para-market circulation of works
An open invitation to fork, modify, and reapply the model for other self-organized artist cohorts
Who It's For

coldstart is designed for artists, designers, and theorists who are:

Interested in building collective infrastructure for production and distribution
Operating outside (or in critical relation to) traditional galleries and markets
Eager to engage with technological tooling like smart contracts, GitHub, and digital fabrication workflows
Committed to modeling alternatives, rather than merely critiquing dominant systems
How It Works

Each iteration follows a simple structure:

A cohort of 5–10 contributors is assembled
Contributors submit work to a shared production partner
A smart contract encodes revenue splits and automates sales through a shared online storefront
After the edition sells, proceeds are automatically distributed among contributors and producers
The cohort reconvenes to evaluate and iterate the protocol, publishing updates via GitHub
coldstart is not fixed. It is designed to mutate.

Technology Stack

Smart Contract:
ERC721-based (Ethereum) contract with support for editioning and multi-party (artist, production partner, operator) revenue split registration.
Minting and edition management are restricted to the contract owner (admin). Metadata URIs are stored in the contract, with support for off-chain storage (e.g. IPFS).
Frontend:
React-based UI (using Vite) for interacting with the smart contract.
The UI enables artists, production partners, and operators to register wallet addresses, set edition information, and manage basic operations without coding.
Repository Contents

The current protocol version
Smart contract specifications (contracts/ArtistEditionNFT.sol)
Submission templates
Documentation of core principles (4E / 3I models)
Editable diagrams and planning documents
React UI code (see /front-end or /artist-printer-ui as appropriate)
License

coldstart is released under an MIT License, and all contributors are encouraged to fork, adapt, and extend the protocol.

For technical documentation and usage, see the README in the UI directory and inline comments in the smart contract.
