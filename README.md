# GhoSafe: Cross-Chain DeFi Lending Platform

## Overview

GhoSafe is an innovative DeFi lending platform designed to revolutionise the blockchain lending market. It allows users to stake assets, manage loans, and utilise cross-chain collateral, all through a network of interconnected smart contracts.

## Key Features

- **Cross-Chain Collateral**: Leverages Chainlink's CCIP for secure, efficient cross-chain interactions.
- **Aave Integration**: Implements Aave's lending protocols, including credit delegation and GHO token transactions.
- **ConnectKit Integration**: Offers a seamless user experience for wallet connections, powered by Family's ConnectKit.
- **Vaults and Credit Delegation**: Users can create vaults for managing GHO tokens and delegate credit securely.

## Prizes Qualification

GhoSafe is competing for several prizes in the hackathon, including:

- **Aave Payments Prize**: For building tooling to simplify GHO token transactions.
- **Aave Vaults Prize**: For utilising smart contract vaults in innovative ways with GHO.
- **Aave Facilitators Prize**: For potential facilitators for GHO.
- **Aave Integration Prize**: For integrating GHO into GhoSafe's functionalities.
- **Chainlink Prize**: For meaningfully using Chainlink's CCIP with GHO.
- **Family's Pool Prize**: For integrating ConnectKit.

## Deployments

### Sepolia Testnet

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

### Mumbai Testnet

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
