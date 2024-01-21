// File: contracts/Mumbai/interfaces/IAccessManagerMumbai.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IAccessControlDefaultAdminRules } from "@openzeppelin/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";

/**
 * @title IAccessManagerMumbai Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the AccessManagerMumbai contract
 * @dev This interface should be implemented by the AccessManagerMumbai contract.
 */
interface IAccessManagerMumbai is IAccessControlDefaultAdminRules {
	/**
	 * @notice Grant owner role to a new address
	 * @param _newOwner Address of the new owner
	 */
	function grantOwnerRole(address _newOwner) external;

	/**
	 * @notice Revoke owner role from an address
	 * @param _oldOwner Address of the old owner
	 */
	function revokeOwnerRole(address _oldOwner) external;

	/**
	 * @notice Returns the owner role
	 * @return Owner role
	 */
	function OWNER_ROLE() external view returns (bytes32);

	/// @notice Unauthorized access error.
	error UnauthorizedAccess(address caller);
}
