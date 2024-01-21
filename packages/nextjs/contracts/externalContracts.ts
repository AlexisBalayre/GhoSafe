import abiAccessManager from "../../hardhat/artifacts/contracts/Sepolia/users/AccessManagerSepolia.sol/AccessManagerSepolia.json";
import abiLoanManager from "../../hardhat/artifacts/contracts/Sepolia/users/LoanManagerSepolia.sol/LoanManagerSepolia.json";
import abiLoanSafe from "../../hardhat/artifacts/contracts/Sepolia/users/LoanSafeSepolia.sol/LoanSafeSepolia.json";
import abiMailbox from "../../hardhat/artifacts/contracts/Sepolia/users/MailboxSepolia.sol/MailboxSepolia.json";
import abiMessenger from "../../hardhat/artifacts/contracts/Sepolia/users/MessengerSepolia.sol/MessengerSepolia.json";
import abiAccessManagerMumbai from "../../hardhat/artifacts/contracts/Mumbai/users/AccessManagerMumbai.sol/AccessManagerMumbai.json";
import abiMessengerMumbai from "../../hardhat/artifacts/contracts/Mumbai/users/MessengerMumbai.sol/MessengerMumbai.json";
import abiLoanSafeMumbai from "../../hardhat/artifacts/contracts/Mumbai/users/LoanSafeMumbai.sol/LoanSafeMumbai.json";
import abiBoredApeYachtClub from "../../hardhat/artifacts/contracts/Sepolia/users/NftTest.sol/BoredApeYachtClub.json";

const externalContracts = {
    11155111: {
        AccessManagerSepolia: {
            address: "0x08C0712FFF89bD95De9A89669fFAF8a249da4E2e",
            abi: abiAccessManager.abi
        },
        LoanManagerSepolia: {
            address: "0x1380d2e4CE9306c202b8eD9e03Cd50E174db43c0",
            abi: abiLoanManager.abi
        },
        LoanSafeSepolia: {
            address: "0xB42474ad11B695A0C33A34F570aEAd1c21983868",
            abi: abiLoanSafe.abi
        },
        MessengerSepolia: {
            address: "0x3E54F172049736a85bB427f7cAA01B98Faa7F7B2",
            abi: abiMessenger.abi
        },
        MailboxSepolia: {
            address: "0x93446087674906C8d8CEcBfC17fCFCe6E59551D6",
            abi: abiMailbox.abi
        },
        BoredApeYachtClub: {
            address: "0x17F74530Ca376D06FD81A40e5ED0774F8905dc56",
            abi: abiBoredApeYachtClub.abi
        }
    },
    80001: {
        AccessManagerMumbai: {
            address: "0x73954cc61bf86e6ec868d29157a446d96171e59a",
            abi: abiAccessManagerMumbai.abi
        },
        MessengerMumbai: {
            address: "0xBa96051E0F7bD40Fba98175c24C2980a5cB738b8",
            abi: abiMessengerMumbai.abi
        },
        LoanSafeMumbai: {
            address: "0xb7754A955308dA37F9D96435CE0DCcDBa8636fA9",
            abi: abiLoanSafeMumbai.abi
        }
    }
} as const;

export default externalContracts;
