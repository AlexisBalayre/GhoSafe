// File: contracts/Sepolia/protocol/GhoSafeIDSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IGhoSafeAccessManagerSepolia } from "../interfaces/IGhoSafeAccessManagerSepolia.sol";
import { IGhoSafeIDSepolia } from "../interfaces/IGhoSafeIDSepolia.sol";

import { ERC165, IERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title GhoSafeIDSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for managing non-transferable tokens associated with users' credit scores.
 */
contract GhoSafeIDSepolia is IGhoSafeIDSepolia, Context, ERC165 {
	/// @dev Token ID counter.
	uint256 private _tokenCounter;

	/// @dev Access manager contract.
	IGhoSafeAccessManagerSepolia internal immutable ACCESS_MANAGER;

	/// @notice Token name.
	string public name;

	/// @notice Token symbol.
	string public symbol;

	/// @dev Mapping from tokenId to the owner address.
	mapping(uint256 => address) private _owners;
	/// @dev Mapping from owner address to tokenId.
	mapping(address => uint256) private _ghoSafeIds;
	/// @dev Mapping from tokenId to Credit Score data.
	mapping(uint256 => CreditScoreData) private _creditScoreData;
	/// @dev Mapping from tokenId to token URI.
	mapping(uint256 => bytes) private _tokenURIs;

	/**
	 * @notice Initializes the contract.
	 * @param _name The token name.
	 * @param _symbol The token symbol.
	 * @param _accessManager The address of the access manager contract.
	 */
	constructor(
		string memory _name,
		string memory _symbol,
		IGhoSafeAccessManagerSepolia _accessManager
	) {
		name = _name;
		symbol = _symbol;
		ACCESS_MANAGER = _accessManager;
	}

	/**
	 * @notice Retrieves the credit score data of a specific token.
	 * @param _tokenId The token ID to retrieve the credit score data of.
	 * @return creditScoreData The credit score data of the specified token.
	 */
	function creditScoreDataOf(
		uint256 _tokenId
	) external view returns (CreditScoreData memory creditScoreData) {
		if (_owners[_tokenId] == address(0)) {
			revert TokenDoesNotExist(_tokenId);
		}
		creditScoreData = _creditScoreData[_tokenId];
	}

	/**
	 * @notice Retrieves the GhoSafe ID of a specific address.
	 * @param _owner The address to retrieve the GhoSafe ID of.
	 * @return tokenId The GhoSafe ID of the specified address.
	 */
	function ghoSafeIdOf(
		address _owner
	) external view returns (uint256 tokenId) {
		tokenId = _ghoSafeIds[_owner];
		if (tokenId == 0) {
			revert TokenDoesNotExist(tokenId);
		}
	}

	/**
	 * @notice Retrieves the balance of a specific address.
	 * @param _owner The address to retrieve the balance of.
	 * @return balance The balance of the specified address.
	 */
	function balanceOf(address _owner) external view returns (uint256 balance) {
		balance = _ghoSafeIds[_owner] == 0 ? 0 : 1;
	}

	/**
	 * @notice Retrieves the owner of a specific token.
	 * @param _tokenId The token ID to retrieve the owner of.
	 * @return owner The owner of the specified token.
	 */
	function ownerOf(uint256 _tokenId) external view returns (address owner) {
		owner = _owners[_tokenId];
		if (owner == address(0)) {
			revert TokenDoesNotExist(_tokenId);
		}
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will always return false as the token is non-transferable.
	 */
	function isApprovedForAll(
		address,
		address
	) external pure returns (bool isApproved) {
		isApproved = false;
	}

	/**
	 * @notice Returns true if this contract implements the interface defined by interfaceId. See the corresponding EIP section to learn more about how these ids are created.
	 * @param  _interfaceId  The interface identifier, as specified in ERC-165.
	 * @return isSupported  True if the contract implements interfaceId.
	 */
	function supportsInterface(
		bytes4 _interfaceId
	)
		public
		view
		override(IGhoSafeIDSepolia, ERC165)
		returns (bool isSupported)
	{
		isSupported = (_interfaceId == type(IERC721Metadata).interfaceId ||
			super.supportsInterface(_interfaceId));
	}

	/**
	 * @notice Returns the URI of the token metadata.
	 * @param _tokenId The ID of the token to get the URI of.
	 * @return A string representing the token URI.
	 */
	function tokenURI(uint256 _tokenId) public view returns (string memory) {
		// Reverts if the token does not exist.
		if (_owners[_tokenId] == address(0)) {
			revert TokenDoesNotExist(_tokenId);
		}
		// Returns the URI
		return (
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(_tokenURIs[_tokenId])
				)
			)
		);
	}

	/**
	 * @notice Mints a new GhoSafe ID token to the specified address.
	 * @param _to The address to mint the token to.
	 * @param _initialCreditScore The initial credit score of the token.
	 * @param _tokenURI The token URI of the token.
	 * @dev Only callable by addresses with the MINTER_ROLE.
	 */
	function safeMint(
		address _to,
		uint256 _initialCreditScore,
		bytes calldata _tokenURI
	) external {
		if (!ACCESS_MANAGER.hasRole(keccak256("MINTER_ROLE"), msg.sender)) {
			revert UnauthorizedAccess(msg.sender);
		}
		if (_ghoSafeIds[_to] != 0) {
			revert GhoSafeIdAlreadyMinted(_to);
		}
		uint256 tokenId = ++_tokenCounter;
		_owners[tokenId] = _to;
		_ghoSafeIds[_to] = tokenId;
		_creditScoreData[tokenId].creditScore = _initialCreditScore;
		_tokenURIs[tokenId] = _tokenURI;
		emit GhoSafeIdMinted(tokenId, _to, _initialCreditScore);
	}

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
	) external {
		if (!ACCESS_MANAGER.hasRole(keccak256("MINTER_ROLE"), msg.sender)) {
			revert UnauthorizedAccess(msg.sender);
		}
		if (_to.length != _initialCreditScore.length) {
			revert InvalidArgumentsLength(
				_initialCreditScore.length,
				_to.length
			);
		}
		if (_to.length != _tokenURI.length) {
			revert InvalidArgumentsLength(_tokenURI.length, _to.length);
		}
		for (uint256 i = 0; i < _to.length; i++) {
			if (_ghoSafeIds[_to[i]] != 0) {
				revert GhoSafeIdAlreadyMinted(_to[i]);
			}
			uint256 tokenId = ++_tokenCounter;
			_owners[tokenId] = _to[i];
			_ghoSafeIds[_to[i]] = tokenId;
			_creditScoreData[tokenId].creditScore = _initialCreditScore[i];
			_tokenURIs[tokenId] = _tokenURI[i];
			emit GhoSafeIdMinted(tokenId, _to[i], _initialCreditScore[i]);
		}
	}

	/**
	 * @notice Updates the credit score of a specific token.
	 * @param _tokenId The token ID to update.
	 * @param _newCreditScore The new credit score of the token.
	 * @param _loansCountIncrement The amount to increment the loans count by.
	 * @param _totalAmountBorrowedIncrement The amount to increment the total amount borrowed by.
	 * @param _totalAmountRepaidIncrement The amount to increment the total amount repaid by.
	 * @dev Only callable by addresses with the CREDIT_SCORE_OFFICER_ROLE.
	 */
	function updateCreditScore(
		uint256 _tokenId,
		uint256 _newCreditScore,
		uint256 _loansCountIncrement,
		uint256 _totalAmountBorrowedIncrement,
		uint256 _totalAmountRepaidIncrement
	) external {
		if (_owners[_tokenId] == address(0)) {
			revert TokenDoesNotExist(_tokenId);
		}
		if (
			!ACCESS_MANAGER.hasRole(
				keccak256("CREDIT_SCORE_OFFICER_ROLE"),
				msg.sender
			)
		) {
			revert UnauthorizedAccess(msg.sender);
		}
		_creditScoreData[_tokenId].loansCount += _loansCountIncrement;
		_creditScoreData[_tokenId]
			.totalAmountBorrowed += _totalAmountBorrowedIncrement;
		_creditScoreData[_tokenId]
			.totalAmountRepaid += _totalAmountRepaidIncrement;
		_creditScoreData[_tokenId].creditScore = _newCreditScore;
		emit CreditScoreUpdated(_tokenId, _newCreditScore);
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will revert as the token is non-transferable.
	 */
	function transferFrom(address, address, uint256) external pure {
		revert TransferNotAllowed();
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will revert as the token is non-transferable.
	 */
	function safeTransferFrom(
		address,
		address,
		uint256,
		bytes memory
	) external pure {
		revert TransferNotAllowed();
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will revert as the token is non-transferable.
	 */
	function safeTransferFrom(address, address, uint256) external pure {
		revert TransferNotAllowed();
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will revert as the token is non-transferable.
	 */
	function setApprovalForAll(address, bool) external pure {
		revert TransferNotAllowed();
	}

	/**
	 * @notice Retrieves the token URI of a specific token.
	 * @dev Will revert as the token is non-transferable.
	 */
	function approve(address, uint256) external pure {
		revert TransferNotAllowed();
	}
}
