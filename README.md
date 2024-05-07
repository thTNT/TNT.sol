# Overview of TNT Token Interaction as a Layer 2 solution

The three contracts, `tnt.sol`, `L2Escrow.sol`, and `L2TokenConvert.sol`, work together to manage and bridge the TNT token between Layer 1 (L1) and Layer 2 (L2). Below is an explanation of each contract's role and how they collectively enable the creation and management of TNT as an L2 token.

## Contracts Overview

### L2Token
`tnt.sol` is an ERC-20 standard token contract with extra functionality for minting and burning, allowing it to operate across blockchain layers. Key features:
- **Minting and Burning**: Controlled by designated roles (escrow and converter) to maintain parity across layers.
- **Access Control**: Ensures that only authorized roles can modify the token supply.

### L2Escrow
`L2Escrow.sol` facilitates the bridging of tokens between L1 and L2. Key responsibilities:
- **Receive and Transfer**: Receives tokens from L1 and interacts with `L2Token` to mint TNT on L2.
- **Burn and Synchronize**: Burns TNT on L2 when tokens are to be transferred back to L1.

### L2TNTConvert
`L2TokenConvert.sol` manages conversion between different token standards or representations on the same layer. Features include:
- **Minting and Burning**: Allows minting and burning based on conversion logic.
- **Access Control**: Role-based controls ensure secure and authorized conversions.

## Creating TNT as an L2 Token

### 1. Token Locking on L1
- When transferring tokens from L1 to L2, an equivalent amount is locked in an escrow-like mechanism on L1, preventing double spending.

### 2. Token Minting on L2
- `L2Escrow` initiates minting of an equivalent amount of TNT on L2 by interacting with the `L2Token` contract, ensuring parity between layers.

### 3. Token Operations on L2
- Once on L2, TNT can be freely transferred, used in decentralized applications, or converted via the `L2TNTConvert`.

### 4. Token Burning and Unlocking
- When returning tokens to L1, an equivalent amount of TNT is burned on L2 to unlock the original tokens on L1, maintaining conservation of the total token supply.

This interaction ensures that TNT tokens remain synchronized across blockchain layers, providing users and applications with a consistent and secure experience. Features like role-based access, upgradability, and pausing further enhance security and adaptability for the TNT token ecosystem.
