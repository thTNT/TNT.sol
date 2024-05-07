
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AccessControlDefaultAdminRulesUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol"; // forgefmt: disable-line
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";

/**
 * @title TNT L2Token
 * @author sepyke.eth
 * @notice Mintable and burnable token by L2Escrow and L2Converter
 */
contract L2Token is AccessControlDefaultAdminRulesUpgradeable, UUPSUpgradeable, ERC20PausableUpgradeable {
    // ****************************
    // *           Roles          *
    // ****************************

    bytes32 public constant ESCROW_ROLE = keccak256("ESCROW_ROLE");
    bytes32 public constant CONVERTER_ROLE = keccak256("CONVERTER_ROLE");

    // ****************************
    // *        Initializer       *
    // ****************************

    /// @notice Disable initializer on deploy
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice TNT L2Token initializer
     * @param _admin The admin address
     * @param _escrow The L2Escrow address
     * @param _converter The Converter address
     * @param _name THRUST
     * @param _symbol TNT
     */
    function initialize(address _admin, address _escrow, address _converter, string memory _name, string memory _symbol) public virtual initializer {
        // Inits
        __AccessControlDefaultAdminRules_init(3 days, _admin);
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ERC20_init(_name, _symbol);

        _grantRole(ESCROW_ROLE, _escrow);
        _grantRole(CONVERTER_ROLE, _converter);
    }

    // ****************************
    // *          Upgrade         *
    // ****************************

    /**
     * @dev Only the owner can upgrade the TNT
     * @param _newVersion The contract address of a new version
     */
    function _authorizeUpgrade(address _newVersion) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // ****************************
    // *          Pause           *
    // ****************************

    /**
     * @notice Pause the TNT L2
     * @dev Only EMERGENCY_ROLE can pause the TNT L2Token
     */
    function pause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Resume the TNT L2Token
     * @dev Only EMERGENCY_ROLE can resume the TNT L2Token
     */
    function unpause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // ****************************
    // *           Bridge         *
    // ****************************

    /**
     * @notice Mint TNT as bridge
     * @param to the recipeint address
     * @param amount the token amount
     */
    function bridgeMint(address to, uint256 amount) external onlyRole(ESCROW_ROLE) whenNotPaused {
        _mint(to, amount);
    }

    /**
     * @notice Burn token as bridge
     * @param from the owner address
     * @param amount the token amount
     */
    function bridgeBurn(address from, uint256 amount) external onlyRole(ESCROW_ROLE) whenNotPaused {
        _burn(from, amount);
    }

    // ****************************
    // *         Converter        *
    // ****************************

    /**
     * @notice Mint TNT as converter
     * @param to the recipeint address
     * @param amount the token amount
     */
    function converterMint(address to, uint256 amount) external onlyRole(CONVERTER_ROLE) whenNotPaused {
        _mint(to, amount);
    }

    /**
     * @notice burn TNT as converter
     * @param from the owner address
     * @param amount the token amount
     */
    function converterBurn(address from, uint256 amount) external onlyRole(CONVERTER_ROLE) whenNotPaused {
        _burn(from, amount);
    }
}
