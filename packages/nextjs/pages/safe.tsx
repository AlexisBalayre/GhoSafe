
import React, { useState, useEffect } from 'react';
import type { NextPage } from "next";
import { useAccount, useWalletClient, useContractRead, useNetwork, useContractWrite, useWaitForTransaction } from 'wagmi';
import { MetaHeader } from '../components/MetaHeader';
import { TokenBalanceDisplay } from '../components/TokenBalanceDisplay';
import { NETWORKS_EXTRA_DATA } from '../utils/scaffold-eth/networks';
import { AddressInput, Address } from "~~/components/scaffold-eth";
import safeABI from '~~/public/abis/SafeSepolia.json';
import loanManagerABI from '~~/public/abis/LoanManagerSepolia.json';
import { DocumentArrowDownIcon } from '@heroicons/react/24/outline';
import { WalletNotConnectedModal } from '~~/components/WalletNotConnectedModal';
import { WrongChainModal } from '~~/components/WrongChainModal';
import {
    TxReceipt,
    getParsedError,
} from "~~/components/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { useTransactor } from '~~/hooks/scaffold-eth';

const Safe: NextPage = () => {
    const { address: userAddress } = useAccount();
    const { data: walletClient } = useWalletClient();
    const { chain } = useNetwork();

    const tokens = NETWORKS_EXTRA_DATA[chain?.id ?? '']?.tokens || {};
    const aaveTokens = NETWORKS_EXTRA_DATA[chain?.id ?? '']?.aTokens || {};
    const ghoTokens = NETWORKS_EXTRA_DATA[chain?.id ?? '']?.ghoTokens || {};

    const [safeAddress, setSafeAddress] = useState('');
    const [isConnectedToSafe, setIsConnectedToSafe] = useState(false);

    const [amountToSupply, setAmountToSupply] = useState(BigInt(0));
    const [tokenAddressToSupply, setTokenAddressToSupply] = useState('');
    const [amountToBorrow, setAmountToBorrow] = useState(BigInt(0));

    const [lastTxType, setLastTxType] = useState(0);

    const {
        data: resultSupplyToAave,
        isLoading: isLoadingSupplyToAave,
        writeAsync: supplyToAave,
    } = useContractWrite({
        abi: safeABI.abi,
        address: safeAddress?.toString(),
        functionName: "supplyToAave",
        args: [
            tokenAddressToSupply,
            amountToSupply,
        ]
    });

    const {
        data: resultBorrowGho,
        isLoading: isLoadingBorrowGho,
        writeAsync: borrowGho,
    } = useContractWrite({
        abi: safeABI.abi,
        address: safeAddress?.toString(),
        functionName: "borrowGho",
        args: [
            amountToBorrow
        ]
    });

    const handleSupplyToAave = async () => {
        if (amountToSupply && tokenAddressToSupply) {
            try {
                setLastTxType(1);
                const makeWriteWithParams = () => supplyToAave();
                await writeTxn(makeWriteWithParams);
            } catch (e: any) {
                const message = getParsedError(e);
                notification.error(message);
            }
        }
    };

    const handleBorrowGho = async () => {
        if (amountToBorrow) {
            try {
                setLastTxType(2);
                const makeWriteWithParams = () => borrowGho();
                await writeTxn(makeWriteWithParams);
            } catch (e: any) {
                const message = getParsedError(e);
                notification.error(message);
            }
        }
    };

    const writeTxn = useTransactor();

    const { data: txResult } = useWaitForTransaction({
        hash: lastTxType === 1 ? resultSupplyToAave?.hash : resultBorrowGho?.hash,
    });

    const connectToSafe = () => {
        console.log('Connecting to Safe at:', safeAddress);
        setIsConnectedToSafe(true);

        // Store safe address in local storage
        localStorage.setItem('safeAddress', safeAddress);
    };

    const deploySafeContract = async () => {
        console.log('Deploying new Safe...');
        const tx = await walletClient?.deployContract({
            abi: safeABI.abi,
            bytecode: `0x${safeABI.bytecode}`,
            args: [
                "0x77D08C620728194fF1A4b3dA458f04975568CF1e", // GhoSafeID
                "0x8E3cDEA3e6e439a49c7958d0bB76254E786b5266", // GhoSafeLoanAdvertisementBook
                0, // Referral code
                "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60", // GhoToken
                "0x67ae46EF043F7A4508BD1d6B94DB6c33F0915844", // DebtGhoToken
                "0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951", // Pool
                "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59", // Router
                "0x779877A7B0D9E8603169DdbD7836e478b4624789", // Link
                userAddress, // Owner
            ]
        });
        console.log('tx:', tx);
    };

    const { data: userAccessManager, isError: isErrorUserAccessManager, isLoading: isLoadingAccessManager } = useContractRead({
        abi: safeABI.abi,
        address: safeAddress,
        functionName: "USER_ACCESS_MANAGER"
    });
    const { data: loanManager, isError: isErrorLoanManager, isLoading: isLoadingLoanManager } = useContractRead({
        abi: safeABI.abi,
        address: safeAddress,
        functionName: "USER_LOAN_MANAGER_ADDRESS"
    });
    const { data: loanSafe, isError: isErrorLoanSafe, isLoading: isLoadingLoanSafe } = useContractRead({
        abi: loanManagerABI.abi,
        address: loanManager?.toString(),
        functionName: "USER_LOAN_SAFE"
    });
    const { data: mailbox, isError: isErrorMailbox, isLoading: isLoadingMailbox } = useContractRead({
        abi: safeABI.abi,
        address: safeAddress,
        functionName: "USER_MAILBOX_ADDRESS"
    });
    const { data: messenger, isError: isErrorMessenger, isLoading: isLoadingMessenger } = useContractRead({
        abi: loanManagerABI.abi,
        address: loanManager?.toString(),
        functionName: "USER_MESSENGER"
    });

    useEffect(() => {
        // Read wagmi.connected from localStorage
        const connected = localStorage.getItem("wagmi.connected");
        if (!connected) {
            // Open the modal
            (document.getElementById("wallet_not_connected") as HTMLDialogElement)?.showModal();
            //router.push("/");
        }

        if (chain?.id?.toString() !== '11155111' && connected && walletClient?.account) {
            // Open the modal
            (document.getElementById("wrong_chain") as HTMLDialogElement)?.showModal();
            //router.push("/");
        }

        const safeAddress = localStorage.getItem('safeAddress');
        if (safeAddress && userAddress) {
            setSafeAddress(safeAddress);
            setIsConnectedToSafe(true);
        }
    });

    const renderContractData = (label: string, data: any, isLoading: boolean, isError: boolean) => {
        if (isLoading) return <p className='font-bold'>Loading {label}...</p>;
        if (isError || !data) return <p>Error loading {label}</p>;
        return <div className="flex justify-between w-full text-center place-self-center">
            <p>{label}</p>
            <Address address={data.toString()} />
        </div>;
    };

    const openModal = () => {
        (document.getElementById('addr') as HTMLDialogElement).showModal();
    }

    return (
        <div className="m-10 grid">
            <MetaHeader title="Safe | GhoSafe Protocol" />

            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Safe</h1>
                <Address address={safeAddress} format='long' size='xl' />
            </div>

            {!isConnectedToSafe ? (
                <div className="justify-center content-center">
                    <AddressInput
                        onChange={setSafeAddress}
                        value={safeAddress}
                        placeholder="Input Safe Address"
                    />
                    <div className="flex justify-center space-x-4 mt-20">
                        <button className="btn btn-primary" onClick={connectToSafe}>Connect to Safe</button>
                        <button className="btn btn-secondary" onClick={deploySafeContract}>Deploy New Safe</button>
                    </div>
                </div>
            ) : (
                <>
                    <div className="grid text-center">
                        <span className='flex flex-row items-center' > {/* Use items-center for vertical alignment */}
                            <DocumentArrowDownIcon className="h-6 w-6 mr-2" /> {/* Add margin-right for spacing */}
                            <p className="text-sm cursor-pointer hover:text-secondary" onClick={openModal}>See Addresses</p>
                        </span>

                        <dialog id="addr" className="modal">
                            <div className="modal-box">
                                <div className='grid rounded-xl'>
                                    <h2 className="text-2xl font-bold mb-10 text-center">Addresses</h2>
                                    {renderContractData("SAFE", safeAddress, false, false)}
                                    {renderContractData("ACCESS_MANAGER", userAccessManager, isLoadingAccessManager, isErrorUserAccessManager)}
                                    {renderContractData("LOAN_MANAGER", loanManager, isLoadingLoanManager, isErrorLoanManager)}
                                    {renderContractData("LOAN_SAFE", loanSafe, isLoadingLoanSafe, isErrorLoanSafe)}
                                    {renderContractData("MAILBOX", mailbox, isLoadingMailbox, isErrorMailbox)}
                                    {renderContractData("MESSENGER", messenger, isLoadingMessenger, isErrorMessenger)}
                                </div>
                            </div>
                            <form method="dialog" className="modal-backdrop">
                                <button>close</button>
                            </form>
                        </dialog>

                        {txResult ? (
                            <div className="flex-grow basis-0">
                                <TxReceipt txResult={txResult} />
                            </div>
                        ) : null}

                        <div>
                            <dialog id="supply" className="modal">
                                <div className="modal-box">
                                    <h3 className="font-bold text-lg text-center">Supply to AAVE</h3>
                                    <div className="grid">
                                        <div className="">
                                            <p className="text-sm">Amount (in WEI)</p>
                                            <input className='input input-bordered input-primary' type="number" onChange={(e) => setAmountToSupply(BigInt(e.target.value))} />
                                        </div>
                                        <div className="">
                                            <p className="text-sm">Token Address</p>
                                            <AddressInput
                                                onChange={setTokenAddressToSupply}
                                                value={tokenAddressToSupply}
                                                placeholder="Token Address"
                                            />
                                        </div>
                                        <button className="btn btn-primary mt-10 w-1/3 place-self-center" disabled={isLoadingSupplyToAave} onClick={handleSupplyToAave}>
                                            {isLoadingSupplyToAave && <span className="loading loading-spinner loading-xs"></span>}
                                            Send Transaction
                                        </button>
                                    </div>
                                </div>
                                <form method="dialog" className="modal-backdrop">
                                    <button>Close</button>
                                </form>
                            </dialog>
                        </div>

                        <div>
                            <dialog id="borrowGho" className="modal">
                                <div className="modal-box">
                                    <h3 className="font-bold text-lg text-center">Borrow GHO</h3>
                                    <div className="grid">
                                        <div className="">
                                            <p className="text-sm">Amount (in WEI)</p>
                                            <input className='input input-bordered input-primary' type="number" onChange={(e) => setAmountToBorrow(BigInt(e.target.value))} />
                                        </div>
                                        <button className="btn btn-primary mt-10 w-1/3 place-self-center" disabled={isLoadingBorrowGho} onClick={handleBorrowGho}>
                                            {isLoadingBorrowGho && <span className="loading loading-spinner loading-xs"></span>}
                                            Send Transaction
                                        </button>
                                    </div>
                                </div>
                                <form method="dialog" className="modal-backdrop">
                                    <button>Close</button>
                                </form>
                            </dialog>
                        </div>

                        <div className="grid items-center my-2 rounded-md shadow-mdn mt-10">
                            <h2 className="text-2xl font-bold mb-10 text-center">Safe Balance - Gho Token</h2>
                            {Object.entries(ghoTokens).map(([key, token]) => (
                                <TokenBalanceDisplay
                                    key={key}
                                    tokenSymbol={token.symbol}
                                    tokenAddress={token.address}
                                    logoUrl={token.logoURI}
                                    address={safeAddress}
                                />
                            ))}
                            <button className="btn btn-primary" onClick={() => (document.getElementById('borrowGho') as HTMLDialogElement)?.showModal()}>Borrow GHO</button>
                        </div>

                        <div className="grid items-center my-2 rounded-md shadow-mdn mt-10">
                            <h2 className="text-2xl font-bold mb-10 text-center">Safe Balance - Regular Assets</h2>
                            {Object.entries(tokens).map(([key, token]) => (
                                <TokenBalanceDisplay
                                    key={key}
                                    tokenSymbol={token.symbol}
                                    tokenAddress={token.address}
                                    logoUrl={token.logoURI}
                                    address={safeAddress}
                                />
                            ))}
                            <button className="btn btn-primary" onClick={() => (document.getElementById('supply') as HTMLDialogElement)?.showModal()}>Supply to AAVE</button>
                        </div>

                        <div className="grid items-center my-2 rounded-md shadow-mdn mt-10">
                            <h2 className="text-2xl font-bold mb-10 text-center">Safe Balance - Aave Tokens</h2>
                            {Object.entries(aaveTokens).map(([key, token]) => (
                                <TokenBalanceDisplay
                                    key={key}
                                    tokenSymbol={token.symbol}
                                    tokenAddress={token.address}
                                    logoUrl={token.logoURI}
                                    address={safeAddress}
                                />
                            ))}
                        </div>

                    </div>

                </>
            )}
            <WalletNotConnectedModal />
            <WrongChainModal goodChain="Sepolia" />
        </div>
    );
};

export default Safe;

