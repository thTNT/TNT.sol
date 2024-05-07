// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AccessControlDefaultAdminRulesUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol"; // forgefmt: disable-line
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IL2Token} from "./interfaces/IL2Token.sol";

/**
 * @title TNT L2TokenConverter
 * @author sepyke.eth
 * @dev Receives ERC20 and send L2Token at specified exchange rate
 */
contract L2TokenConverter is AccessControlDefaultAdminRulesUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    // ****************************
    // *         Libraries        *
    // ****************************

    using SafeERC20 for IERC20Metadata;

    // ****************************
    // *           Roles          *
    // ****************************

    bytes32 public constant ESCROW_MANAGER_ROLE = keccak256("ESCROW_MANAGER_ROLE");
    bytes32 public constant RISK_MANAGER_ROLE = keccak256("RISK_MANAGER_ROLE");

    // ****************************
    // *      ERC-7201 Storage    *
    // ****************************

    /// @custom:storage-location erc7201:polygon.storage.L2TokenConverter
    struct L2TokenConverterStorage {
        IL2Token target;
        mapping(IERC20Metadata source => uint256 max) issuances;
    }

    // keccak256(abi.encode(uint256(keccak256("polygon.storage.L2TokenConverter")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant L2TokenConverterStorageLocation = 0x3bb72e938ae6c075bccfb66342f4d160e450009bc92ac6588be7b0c22fb29900;

    function _getL2TokenConverterStorage() private pure returns (L2TokenConverterStorage storage $) {
        assembly {
            $.slot := L2TokenConverterStorageLocation
        }
    }

    function getMaxIssuance(IERC20Metadata _token) public view virtual returns (uint256) {
        L2TokenConverterStorage storage $ = _getL2TokenConverterStorage();
        return $.issuances[_token];
    }

    // ****************************
    // *           Event          *
    // ****************************

    event IssuanceUpdated(IERC20Metadata indexed token, uint256 amount);
    event Deposit(IERC20Metadata indexed token, address sender, address recipient, uint256 amount);
    event Withdraw(IERC20Metadata indexed token, address sender, address recipient, uint256 amount);
    event ManagerWithdraw(IERC20Metadata indexed token, address recipient, uint256 amount);

    // ****************************
    // *           Error          *
    // ****************************

    error TokenDecimalsInvalid();
    error MaxIssuance();

    // ****************************
    // *        Initializer       *
    // ****************************

    /// @notice Disable initializer on deploy
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice L2TokenConverter initializer
     * @param _admin The admin address
     * @param _escrow The escrow manager address
     * @param _risk The risk manager address
     * @param _l2Token The L2Token address
     */
    function initialize(address _admin, address _escrow, address _risk, address _l2Token) public virtual initializer {
        // Inits
        __AccessControlDefaultAdminRules_init(3 days, _admin);
        __UUPSUpgradeable_init();
        __Pausable_init();

        _grantRole(ESCROW_MANAGER_ROLE, _escrow);
        _grantRole(RISK_MANAGER_ROLE, _risk);

        L2TokenConverterStorage storage $ = _getL2TokenConverterStorage();
        $.target = IL2Token(_l2Token);
    }

    // ****************************
    // *          Upgrade         *
    // ****************************

    /**
     * @dev Only the owner can upgrade the L1Escrow
     * @param _newVersion The contract address of a new version
     */
    function _authorizeUpgrade(address _newVersion) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // ****************************
    // *          Pause           *
    // ****************************

    /**
     * @notice Pause the L1Escrow
     * @dev Only EMERGENCY_ROLE can pause the L1Escrow
     */
    function pause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Resume the L1Escrow
     * @dev Only EMERGENCY_ROLE can resume the L1Escrow
     */
    function unpause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // ****************************
    // *      L2Token Issuance    *
    // ****************************

    /// @dev Set issuance cap for source token (ERC-20) <-> target token (L2Token)
    /// @dev Risk manager can execute this function multiple time in order to reduce or increase the issuance cap
    /// @param _token ERC-20 address
    /// @param _max maximum amount
    function setIssuanceCap(IERC20Metadata _token, uint256 _max) external virtual onlyRole(RISK_MANAGER_ROLE) whenNotPaused {
        L2TokenConverterStorage storage $ = _getL2TokenConverterStorage();
        if (_token.decimals() != IERC20Metadata(address($.target)).decimals()) revert TokenDecimalsInvalid();
        $.issuances[_token] = _max;
        emit IssuanceUpdated(_token, _max);
    }

    /// @dev User can deposit ERC-20 in exchange for L2Token
    function deposit(IERC20Metadata _token, address _recipient, uint256 _amount) external virtual whenNotPaused {
        L2TokenConverterStorage storage $ = _getL2TokenConverterStorage();
        uint256 maxIssuance = $.issuances[_token];
        if (_amount > maxIssuance) revert MaxIssuance();

        // Reduce max issuance
        $.issuances[_token] -= _amount;

        _token.safeTransferFrom(msg.sender, address(this), _amount);
        $.target.converterMint(_recipient, _amount);

        emit Deposit(_token, msg.sender, _recipient, _amount);
    }

    /// @dev User can withdraw ERC-20 by burning L2Token
    function withdraw(IERC20Metadata _token, address _recipient, uint256 _amount) external virtual whenNotPaused {
        L2TokenConverterStorage storage $ = _getL2TokenConverterStorage();

        // Freed up some issuance quota
        $.issuances[_token] += _amount;

        $.target.converterBurn(msg.sender, _amount);
        _token.safeTransfer(_recipient, _amount);

        emit Withdraw(_token, msg.sender, _recipient, _amount);
    }

    // ****************************
    // *          Manager         *
    // ****************************

    /**
     * @dev Escrow manager can withdraw the token backing
     * @param _recipient the recipient address
     * @param _amount The amount of token
     */
    function managerWithdraw(IERC20Metadata _token, address _recipient, uint256 _amount) external virtual onlyRole(ESCROW_MANAGER_ROLE) whenNotPaused {
        _token.safeTransfer(_recipient, _amount);
        emit ManagerWithdraw(_token, _recipient, _amount);
    }
}
