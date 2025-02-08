# TokenAirDrop - Bagel Token Airdrop

## Overview
TokenAirDrop is a Foundry-based project that enables users to claim **Bagel** tokens through a Merkle tree-based airdrop mechanism. The unique feature of this project allows users to claim tokens on behalf of others, ensuring efficient and secure token distribution.

## Features
- **Merkle Tree Integration**: Uses a Merkle tree to verify eligible addresses for airdrop claims.
- **Claim on Behalf**: Users can claim tokens not only for themselves but also for others.
- **Secure and Efficient**: Merkle proof verification ensures only whitelisted addresses receive tokens.
- **Built with Foundry**: Utilizes Foundry for smart contract development and testing.

## Prerequisites
Ensure you have the following installed:
- [Foundry](https://getfoundry.sh/) (for compiling, deploying, and testing contracts)
- Node.js and npm/yarn (for scripting and interaction)
- Metamask or any other Ethereum-compatible wallet

## Installation
Clone the repository and install dependencies:
```sh
git clone https://github.com/your-username/TokenAirDrop.git
cd TokenAirDrop
forge install
