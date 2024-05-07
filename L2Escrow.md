# L2Escrow Documentation

## Overview
The `L2Escrow` contract facilitates bridging tokens between Layer 1 (L1) and Layer 2 (L2) by managing wrapped token transfers. This contract interacts with the L1 equivalent (`L1Escrow`) to receive messages and ensures seamless handling of tokens through minting and burning operations. The contract is upgradeable, pausable, and utilizes a custom storage layout for secure management.

## Key Features
- **Access Control**: Enforces role-based access controls using OpenZeppelin's upgradeable access control.
- **Upgradability**: Supports seamless upgrades using the UUPS pattern.
- **Token Management**: Handles minting and burning operations for the wrapped tokens.
- **Bridging Mechanism**: Interacts with `PolygonERC20BridgeBaseUpgradeable` to securely manage tokens between chains.

## Storage Structure
### `L2EscrowStorage`
Defines two main properties:
- **`originTokenAddress`**: The original ERC-20 token's address.
- **`wrappedTokenAddress`**: The wrapped ERC-20 token on Polygon ZkEVM.

### Storage Location
Uses the custom location `L2EscrowStorageLocation`.

### Accessor Functions
- **`_getL2EscrowStorage`**: Returns the `L2EscrowStorage` struct using inline assembly.
- **`originTokenAddress`**: Returns the address of the original ERC-20 token.
- **`wrappedTokenAddress`**: Returns the address of the wrapped L2 token.

## Contract Lifecycle
### Constructor
- **`constructor`**: Disables initializers on deployment to prevent accidental initialization.

### Initializer
- **`initialize`**: Initializes the contract with the following parameters:
  - `_admin`: The admin address.
  - `_polygonZkEVMBridge`: Polygon ZkEVM bridge address.
  - `_counterpartContract`: The counterpart contract address on L1.
  - `_counterpartNetwork`: Network identifier of the counterpart network.
  - `_originTokenAddress`: The original token's address on L1.
  - `_wrappedTokenAddress`: The wrapped L2 token address.

## Upgrade Functionality
### `_authorizeUpgrade`
Ensures that only the default admin role can authorize contract upgrades.

## Pausing Mechanisms
- **`pause`**: Pauses the L2Escrow contract, restricting sensitive functions to authorized users. Only callable by the default admin role.
- **`unpause`**: Resumes the L2Escrow contract, allowing full operation again. Only callable by the default admin role.

## Bridging Mechanisms
### `_receiveTokens`
- **Purpose**: Handles the reception of tokens.
- **Parameters**:
  - `amount`: The amount of tokens to receive.
- **Process**: Burns the wrapped L2 tokens via `bridgeBurn`.

### `_transferTokens`
- **Purpose**: Handles the transfer of tokens to the other network.
- **Parameters**:
  - `destinationAddress`: The destination address to receive tokens.
  - `amount`: The amount of tokens to transfer.
- **Process**: Mints the wrapped L2 tokens via `bridgeMint`.

