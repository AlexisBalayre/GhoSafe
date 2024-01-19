// File: contracts/Sepolia/users/AccessManagerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { AccessControlDefaultAdminRules } from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

/**
 * @title AccessManagerSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for setting up access to users contracts
 */
contract AccessManagerSepolia is AccessControlDefaultAdminRules {
	/// @notice Owner role
	bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

	/// @notice Unauthorized access error.
	error UnauthorizedAccess(address caller);

	/**
	 * @notice Constructor
	 * @param _owner Owner address
	 */
	constructor(
		address _owner
	)
		AccessControlDefaultAdminRules(
			3 days,
			msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
		)
	{
		_grantRole(OWNER_ROLE, _owner);
	}

	/**
	 * @dev Throws if called by any account other than the default admin.
	 */
	modifier onlyAdmin() {
		if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
			revert UnauthorizedAccess(_msgSender());
		}
		_;
	}

	/**
	 * @notice Grant owner role to a new address
	 * @param _newOwner Address of the new owner
	 */
	function grantOwnerRole(address _newOwner) external onlyAdmin {
		_grantRole(OWNER_ROLE, _newOwner);
	}

	/**
	 * @notice Revoke owner role from an address
	 * @param _oldOwner Address of the old owner
	 */
	function revokeOwnerRole(address _oldOwner) external onlyAdmin {
		_revokeRole(OWNER_ROLE, _oldOwner);
	}
}
