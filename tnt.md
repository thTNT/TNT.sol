# TNT L2Token Documentation

## Overview
`L2Token` is a UUPS-upgradeable smart contract representing the TNT token on layer 2 (L2). This token can be minted and burned by the L2 Escrow and Converter contracts, following strict role-based access control. The contract also provides functionalities like pausing and upgrading, ensuring secure and flexible token management.

## Libraries and Inheritance
- **Inheritance**:
  - `AccessControlDefaultAdminRulesUpgradeable`: Provides access control with default admin rules.
  - `UUPSUpgradeable`: Enables proxy upgrades.
  - `ERC20PausableUpgradeable`: ERC-20 token with pausing capability.

## Roles
- **`ESCROW_ROLE`**: Allows minting and burning of TNT tokens through the bridge.
- **`CONVERTER_ROLE`**: Allows minting and burning of TNT tokens via the converter.

## Contract Lifecycle
### Constructor
- `constructor`: Disables the initializer function upon deployment to prevent unintentional initialization.

### Initializer
- `initialize`: Initializes the token contract with:
  - An admin address to manage the roles.
  - Addresses for escrow and converter contracts.
  - The token name and symbol.

## Upgrade Functionality
### `_authorizeUpgrade`
- Ensures that only the default admin can authorize upgrades.

## Pausing Mechanisms
- `pause`: Pauses the minting and burning of tokens. Only callable by the default admin.
- `unpause`: Resumes minting and burning operations. Only callable by the default admin.

## Bridge Operations
### `bridgeMint`
- Mints new TNT tokens to a specified address via the bridge.
- **Access**: `ESCROW_ROLE`.
- **Conditions**: Must be called when the contract is not paused.

### `bridgeBurn`
- Burns a specified amount of TNT tokens from a specified address via the bridge.
- **Access**: `ESCROW_ROLE`.
- **Conditions**: Must be called when the contract is not paused.

## Converter Operations
### `converterMint`
- Mints new TNT tokens to a specified address via the converter.
- **Access**: `CONVERTER_ROLE`.
- **Conditions**: Must be called when the contract is not paused.

### `converterBurn`
- Burns a specified amount of TNT tokens from a specified address via the converter.
- **Access**: `CONVERTER_ROLE`.
- **Conditions**: Must be called when the contract is not paused.
