# GhoSafe: Cross-Chain DeFi Lending Platform

## Overview

GhoSafe is an innovative DeFi lending platform designed to revolutionise the blockchain lending market. It allows users to stake assets, manage loans, and utilise cross-chain collateral, all through a network of interconnected smart contracts.

## Key Features

- **Cross-Chain Collateral**: Leverages Chainlink's CCIP for secure, efficient cross-chain interactions.
- **Aave Integration**: Implements Aave's lending protocols, including credit delegation and GHO token transactions.
- **ConnectKit Integration**: Offers a seamless user experience for wallet connections, powered by Family's ConnectKit.
- **Vaults and Credit Delegation**: Users can create vaults for managing GHO tokens and delegate credit securely.

<img width="1113" alt="ghosafe" src="https://github.com/AlexisBalayre/GhoSafe/assets/60859013/af80a101-09fc-4bbd-8754-497e7ce7323f">

## Prizes Qualification

GhoSafe is competing for several prizes in the hackathon, including:

- **Aave Vaults Prize**: For utilising smart contract vaults in innovative ways with GHO.
- **Aave Integration Prize**: For integrating GHO into GhoSafe's functionalities.
- **Chainlink Prize**: For meaningfully using Chainlink's CCIP with GHO.
- **Family's Pool Prize**: For integrating ConnectKit.

## GhoSafe Smart Contracts Overview

GhoSafe leverages a series of smart contracts to provide a comprehensive DeFi lending platform. Below is an overview of each contract and its utility within the ecosystem.

<img width="1511" alt="Screenshot 2024-01-21 at 16 59 36" src="https://github.com/AlexisBalayre/GhoSafe/assets/60859013/fdc32886-8c70-46ad-9a70-8e6892b0a3f8">
<img width="1511" alt="Screenshot 2024-01-21 at 16 59 36" src="https://github.com/AlexisBalayre/GhoSafe/assets/60859013/04e40d20-fdf2-4c36-8557-4e464c06e4af">

### Protocol Contracts (Deployed on Sepolia)

#### `GhoSafeAccessManagerSepolia`
- **Purpose**: Manages access control within the GhoSafe protocol.
- **Functionality**: Grants and revokes roles to different entities, ensuring secure and authorized interactions with the protocol.

#### `GhoSafeIDSepolia`
- **Purpose**: Manages non-transferable tokens associated with users' credit scores.
- **Functionality**: Assigns and updates credit scores based on users' borrowing and repayment behaviors, facilitating a trust-based lending system.

#### `GhoSafeLoanAdvertisementBookSepolia`
- **Purpose**: Handles the publication and management of loan advertisements.
- **Functionality**: Allows users to advertise available loans, setting terms such as interest rates and durations, thereby connecting lenders and borrowers.

### User Contracts (Deployed by Each User on Sepolia)

#### `AccessManagerSepolia`
- **Purpose**: Sets up and manages access to user-specific contracts.
- **Functionality**: Controls permissions for user-contract interactions, enhancing security and personalization.

#### `SafeSepolia`
- **Purpose**: Acts as a wallet contract for managing funds and interacting with Aave.
- **Functionality**: Enables users to deposit, withdraw, supply to Aave, borrow from Aave, and manage GHO tokens.

#### `LoanManagerSepolia`
- **Purpose**: Oversees the management of loans.
- **Functionality**: Facilitates loan creation, approval, repayment, and liquidation processes, ensuring smooth loan lifecycle management.

#### `LoanSafeSepolia`
- **Purpose**: Safekeeps loans collateral.
- **Functionality**: Holds and manages collateral for loans, ensuring security and proper handling during loan lifecycles.

#### `MailboxSepolia`
- **Purpose**: Used by delegees to create loan requests.
- **Functionality**: Allows borrowers to request loans, detailing their terms and linking to their credit scores for lender assessment.

#### `MessengerSepolia`
- **Purpose**: Facilitates transferring messages and data between chains.
- **Functionality**: Employs Chainlink CCIP for cross-chain interactions, crucial for managing loans with cross-chain collateral.

### User Contracts (Deployed on Mumbai)

#### `AccessManagerMumbai`
- **Purpose**: Manages access for user contracts on the Mumbai chain.
- **Functionality**: Similar to its Sepolia counterpart, it controls permissions for user-contract interactions on Mumbai.

#### `MessengerMumbai`
- **Purpose**: Handles cross-chain messaging specific to the Mumbai chain.
- **Functionality**: Works alongside `MessengerSepolia` to facilitate cross-chain loan operations and collateral management.

#### `LoanSafeMumbai`
- **Purpose**: Manages collateral for loans on the Mumbai chain.
- **Functionality**: Ensures the safekeeping and proper handling of collateral for cross-chain loans initiated on Mumbai.

## Deployments

### Sepolia Testnet (Core Protocol)

| Contract                            | Address                                                                                                                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| GhoSafeAccessManagerSepolia         | [0x124AE849075ff729Ffdf49a49519777206F6fF64](https://sepolia.etherscan.io/address/0x124AE849075ff729Ffdf49a49519777206F6fF64) |
| GhoSafeIDSepolia                    | [0x77D08C620728194fF1A4b3dA458f04975568CF1e](https://sepolia.etherscan.io/address/0x77D08C620728194fF1A4b3dA458f04975568CF1e) |
| GhoSafeLoanAdvertisementBookSepolia | [0x8E3cDEA3e6e439a49c7958d0bB76254E786b5266](https://sepolia.etherscan.io/address/0x8E3cDEA3e6e439a49c7958d0bB76254E786b5266) |
| AccessManagerSepolia                | [0x08C0712FFF89bD95De9A89669fFAF8a249da4E2e](https://sepolia.etherscan.io/address/0x08C0712FFF89bD95De9A89669fFAF8a249da4E2e) |
| SafeSepolia                         | [0x1eD8fd8e8Ad26a88bB5261068776f73ECad9a6f3](https://sepolia.etherscan.io/address/0x1eD8fd8e8Ad26a88bB5261068776f73ECad9a6f3) |
| LoanManagerSepolia                  | [0x1380d2e4CE9306c202b8eD9e03Cd50E174db43c0](https://sepolia.etherscan.io/address/0x1380d2e4CE9306c202b8eD9e03Cd50E174db43c0) |
| LoanSafeSepolia                     | [0xB42474ad11B695A0C33A34F570aEAd1c21983868](https://sepolia.etherscan.io/address/0xB42474ad11B695A0C33A34F570aEAd1c21983868) |
| MailboxSepolia                      | [0x93446087674906C8d8CEcBfC17fCFCe6E59551D6](https://sepolia.etherscan.io/address/0x93446087674906C8d8CEcBfC17fCFCe6E59551D6) |
| MessengerSepolia                    | [0x3E54F172049736a85bB427f7cAA01B98Faa7F7B2](https://sepolia.etherscan.io/address/0x3E54F172049736a85bB427f7cAA01B98Faa7F7B2) |

### Mumbai Testnet (Cross-Chain Collateral)

| Contract            | Address                                                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| AccessManagerMumbai | [0x73954cc61bf86e6ec868d29157a446d96171e59a](https://mumbai.polygonscan.com/address/0x73954cc61bf86e6ec868d29157a446d96171e59a) |
| MessengerMumbai     | [0xBa96051E0F7bD40Fba98175c24C2980a5cB738b8](https://mumbai.polygonscan.com/address/0xBa96051E0F7bD40Fba98175c24C2980a5cB738b8) |
| LoanSafeMumbai      | [0xb7754A955308dA37F9D96435CE0DCcDBa8636fA9](https://mumbai.polygonscan.com/address/0xb7754A955308dA37F9D96435CE0DCcDBa8636fA9) |

## How It's Made

GhoSafe utilises Scaffold-ETH-2 with Hardhat for smart contract development. Key technologies include:

- **Chainlink's CCIP**: For cross-chain data transport.
- **Aave's Lending Protocols**: For implementing lending features.
- **ConnectKit by Family**: For wallet connectivity in dApps.
- **Solidity for Ethereum Smart Contracts**: Core business logic implementation.

## Usage

1. Connect your wallet using ConnectKit.
2. Stake assets in GhoSafe vaults.
3. Utilise cross-chain collateral for loans.
4. Manage your loans and delegate credit.

## License

This project is licensed under the MIT License.
