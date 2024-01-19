// File: contracts/Sepolia/interfaces/IGhoSafeIDSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title IGhoSafeIDSepolia Interface
 * @author GhoSafe Protocol
 * @notice Interface for the GhoSafeIDSepolia contract.
 * @dev This interface should be implemented by the GhoSafeIDSepolia contract.
 */
interface IGhoSafeIDSepolia {
	/**
	 * @notice Struct for storing detailed credit score data.
	 * @param loansCount The number of loans taken out by the token owner.
	 * @param totalAmountBorrowed The total amount borrowed by the token owner.
	 * @param totalAmountRepaid The total amount repaid by the token owner.
	 * @param creditScore The credit score of the token owner.
	 **/
	struct CreditScoreData {
		uint256 loansCount;
		uint256 totalAmountBorrowed;
		uint256 totalAmountRepaid;
		uint256 creditScore;
	}

	/// @notice Not authorized Caller error
	error UnauthorizedAccess(address caller);
	/// @notice Token ID does not exist error
	error TokenDoesNotExist(uint256 tokenId);
	/// @notice GhoSafe ID already minted to an address error
	error GhoSafeIdAlreadyMinted(address owner);
	/// @notice Transfer not allowed error
	error TransferNotAllowed();
	/// @notice Invalid arguments length error
	error InvalidArgumentsLength(uint256 expected, uint256 actual);

	/**
	 * @notice Event emitted when a new GhoSafe ID is minted.
	 * @param tokenId The ID of the GhoSafe ID.
	 * @param owner The address of the GhoSafe ID owner.
	 * @param creditScore The credit score of the GhoSafe ID.
	 **/
	event GhoSafeIdMinted(
		uint256 indexed tokenId,
		address indexed owner,
		uint256 creditScore
	);

	/**
	 * @notice Event emitted when a GhoSafe ID's credit score is updated.
	 * @param tokenId The ID of the GhoSafe ID.
	 * @param creditScore The credit score of the GhoSafe ID.
	 **/
	event CreditScoreUpdated(uint256 indexed tokenId, uint256 creditScore);

	/**
	 * @notice Retrieves the credit score data of a specific token.
	 * @param _tokenId The token ID.
	 * @return creditScoreData The credit score data.
	 */
	function creditScoreDataOf(
		uint256 _tokenId
	) external view returns (CreditScoreData memory creditScoreData);

	/**
	 * @notice Retrieves the GhoSafe ID of a specific address.
	 * @param _owner The address.
	 * @return tokenId The GhoSafe ID.
	 */
	function ghoSafeIdOf(
		address _owner
	) external view returns (uint256 tokenId);

	/**
	 * @notice Retrieves the balance of a specific address.
	 * @param _owner The address.
	 * @return balance The balance.
	 */
	function balanceOf(address _owner) external view returns (uint256 balance);

	/**
	 * @notice Retrieves the owner of a specific token.
	 * @param _tokenId The token ID.
	 * @return owner The owner.
	 */
	function ownerOf(uint256 _tokenId) external view returns (address owner);

	/**
	 * @notice Checks if the contract implements a specific interface.
	 * @param _interfaceId The interface identifier.
	 * @return isSupported True if the contract implements the interface.
	 */
	function supportsInterface(
		bytes4 _interfaceId
	) external view returns (bool isSupported);

	/**
	 * @notice Returns the URI of the token metadata.
	 * @param _tokenId The token ID.
	 * @return tokenURI The token URI.
	 */
	function tokenURI(uint256 _tokenId) external view returns (string memory);

	/**
	 * @notice Mints a new GhoSafe ID token.
	 * @param _to The address to mint the token to.
	 * @param _initialCreditScore The initial credit score.
	 * @param _tokenURI The token URI.
	 */
	function safeMint(
		address _to,
		uint256 _initialCreditScore,
		bytes calldata _tokenURI
	) external;

	/**
	 * @notice Updates the credit score of a specific token.
	 * @param _tokenId The token ID.
	 * @param _newCreditScore The new credit score.
	 * @param _loansCountIncrement The loans count increment.
	 * @param _totalAmountBorrowedIncrement The total amount borrowed increment.
	 * @param _totalAmountRepaidIncrement The total amount repaid increment.
	 */
	function updateCreditScore(
		uint256 _tokenId,
		uint256 _newCreditScore,
		uint256 _loansCountIncrement,
		uint256 _totalAmountBorrowedIncrement,
		uint256 _totalAmountRepaidIncrement
	) external;

	/**
	 * @notice Mints a new GhoSafe ID token to the specified address.
	 * @param _to The address to mint the token to.
	 * @param _initialCreditScore The initial credit score of the token.
	 * @param _tokenURI The token URI of the token.
	 * @dev Only callable by addresses with the MINTER_ROLE.
	 */
	function batchSafeMin(
		address[] calldata _to,
		uint256[] calldata _initialCreditScore,
		bytes[] calldata _tokenURI
	) external;
}
