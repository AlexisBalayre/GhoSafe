// File: contracts/Sepolia/protocol/GhoSafeAccessManagerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { AccessControlDefaultAdminRules } from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

/**
 * @title GhoSafeAccessManagerSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for managing access control to GhoSafe Protocol.
 */
contract GhoSafeAccessManagerSepolia is AccessControlDefaultAdminRules {
	/// @notice Role identifiers for GhoSafe Protocol.
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); 
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	bytes32 public constant LOAN_PUBLISHER_ROLE =
		keccak256("LOAN_PUBLISHER_ROLE");
	bytes32 public constant CREDIT_SCORE_OFFICER_ROLE =
		keccak256("CREDIT_SCORE_OFFICER_ROLE");

	/**
     * @dev Constructor for the GhoSafeAccessManagerSepolia contract.
	 * Here the `DEFAULT_ADMIN_ROLE` is granted to the contract deployer.
	 * The security delay for the change of admin role is set to 3 days.
     */
	constructor()
		AccessControlDefaultAdminRules(
			3 days,
			msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
		)
	{}
}
