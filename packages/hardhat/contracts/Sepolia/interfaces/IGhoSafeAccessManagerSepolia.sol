// File: contracts/Sepolia/interfaces/IGhoSafeAccessManagerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IAccessControlDefaultAdminRules } from "@openzeppelin/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";

/**
 * @title IGhoSafeAccessManagerSepolia Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the GhoSafeAccessManagerSepolia contract
 * @dev This interface should be implemented by the GhoSafeAccessManagerSepolia contract.
 */
interface IGhoSafeAccessManagerSepolia is IAccessControlDefaultAdminRules {
	/**
	 * @notice Returns the role identifier for the ADMIN_ROLE.
	 * @return  bytes32  .
	 */
	function ADMIN_ROLE() external view returns (bytes32);

	/**
	 * @notice Returns the role identifier for the MINTER_ROLE.
	 * @return  bytes32  .
	 */
	function MINTER_ROLE() external view returns (bytes32);

	/**
	 * @notice Returns the role identifier for the BURNER_ROLE.
	 * @return  bytes32  .
	 */
	function CREDIT_SCORE_OFFICER_ROLE() external view returns (bytes32);

	/**
	 * @notice Returns the role identifier for the CREDIT_SCORE_OFFICER_ROLE.
	 * @return  bytes32  .
	 */
	function LOAN_PUBLISHER_ROLE() external view returns (bytes32);

	/**
	 * @notice Returns the role identifier for the IS_WHITELISTED_ROLE.
	 * @return  bytes32  .
	 */
	function IS_WHITELISTED_ROLE() external view returns (bytes32);
}
