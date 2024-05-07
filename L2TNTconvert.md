# L2TokenConverter Documentation

## Overview
The `L2TokenConverter` is a UUPS-upgradeable smart contract that allows users to deposit ERC-20 tokens and receive a specified amount of L2Token TNT. The contract maintains strict controls through the use of roles, pausing mechanisms, and access management, ensuring secure and configurable operations. It provides mechanisms for secure token issuance, conversion, and role-based token withdrawals.

## Libraries and Inheritance
- **Libraries**: The contract uses the `SafeERC20` library from OpenZeppelin to securely handle ERC-20 tokens.
- **Inheritance**:
  - `AccessControlDefaultAdminRulesUpgradeable`
  - `UUPSUpgradeable`
  - `PausableUpgradeable`

## Roles
- `ESCROW_MANAGER_ROLE`: Manages the withdrawal of tokens.
- `RISK_MANAGER_ROLE`: Sets the issuance cap for tokens.

## Storage Structure
### `L2TokenConverterStorage`
The `L2TokenConverterStorage` struct contains:
- `target`: Reference to the L2Token.
- `issuances`: A mapping that holds maximum issuance limits for each ERC-20 token.

### Storage Location
- The `L2TokenConverterStorage` struct uses a custom storage location defined by the constant `L2TokenConverterStorageLocation`.

### Private Storage Accessor
- `_getL2TokenConverterStorage`: A private function that retrieves storage using inline assembly.

## Events
- **`IssuanceUpdated`**: Emitted when the issuance cap for an ERC-20 token is updated.
- **`Deposit`**: Emitted when a user deposits an ERC-20 token to receive L2Token.
- **`Withdraw`**: Emitted when a user withdraws an ERC-20 token by burning L2Token.
- **`ManagerWithdraw`**: Emitted when the escrow manager withdraws tokens.

## Errors
- **`TokenDecimalsInvalid`**: Raised when the ERC-20 and L2Token decimals are mismatched.
- **`MaxIssuance`**: Raised when a deposit exceeds the allowed issuance cap.

## Contract Lifecycle
### Constructor
- `constructor`: Disables the initializer on deployment.

### Initializer
- `initialize`: Sets up roles and assigns the target L2Token. Accepts parameters for the admin, escrow manager, risk manager, and L2Token addresses.

## Upgrade Functionality
### `_authorizeUpgrade`
- Only the default admin can upgrade to a new version of the contract.

## Pausing Mechanisms
- `pause`: Pauses contract actions. Only the default admin can pause.
- `unpause`: Resumes contract actions. Only the default admin can unpause.

## L2Token Issuance
- `setIssuanceCap`: Sets the issuance cap for an ERC-20 token to L2Token conversion. Only callable by the risk manager role.
- `deposit`: Allows users to deposit ERC-20 tokens and receive the corresponding L2Token amount. This reduces the available issuance cap.
- `withdraw`: Allows users to burn L2Token and receive the corresponding ERC-20 tokens. This increases the issuance cap.

## Manager Withdrawals
- `managerWithdraw`: Enables the escrow manager to withdraw ERC-20 tokens directly. Only callable by the escrow manager role.

