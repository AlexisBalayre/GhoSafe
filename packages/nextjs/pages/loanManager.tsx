
import React, { useState, useEffect } from 'react';
import type { NextPage } from "next";
import { useContractRead, useContractWrite, useNetwork, useWaitForTransaction, useWalletClient } from 'wagmi';
import { MetaHeader } from '../components/MetaHeader';
import {
    TxReceipt,
    getParsedError,
} from "~~/components/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { useTransactor } from '~~/hooks/scaffold-eth';
import { Address as AddresScaffold } from "~~/components/scaffold-eth";
import safeABI from '../../hardhat/artifacts/contracts/Sepolia/users/SafeSepolia.sol/SafeSepolia.json';
import loanManagerABI from '../../hardhat/artifacts/contracts/Sepolia/users/LoanManagerSepolia.sol/LoanManagerSepolia.json';
import { DocumentArrowDownIcon } from '@heroicons/react/24/outline';
import { WalletNotConnectedModal } from '~~/components/WalletNotConnectedModal';
import { WrongChainModal } from '~~/components/WrongChainModal';


const LoanManager: NextPage = () => {
    const [safeAddress, setSafeAddress] = useState('');
    const [loanDurationMax, setLoanDurationMax] = useState(3600);
    const [loanInterestRate, setLoanInterestRate] = useState(100);
    const [totalBorrowPowerAvailable, setTotalBorrowPowerAvailable] = useState(10);
    const [maxBorrowPowerPerUser, setMaxBorrowPowerPerUser] = useState(10);

    const { data: walletClient } = useWalletClient();
    const { chain } = useNetwork();

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

    const {
        data: result,
        isLoading,
        writeAsync,
    } = useContractWrite({
        abi: loanManagerABI.abi,
        address: loanManager?.toString(),
        functionName: "setLoanParameters",
        args: [
            loanDurationMax,
            totalBorrowPowerAvailable,
            maxBorrowPowerPerUser,
            loanInterestRate
        ]
    });

    const handleWrite = async () => {
        if (writeAsync) {
            try {
                const makeWriteWithParams = () => writeAsync();
                await writeTxn(makeWriteWithParams);
            } catch (e: any) {
                const message = getParsedError(e);
                notification.error(message);
            }
        }
    };

    const writeTxn = useTransactor();
    const { data: txResult } = useWaitForTransaction({
        hash: result?.hash,
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
        if (safeAddress) {
            setSafeAddress(safeAddress);
        } else {
            // Go to Safe page if not connected to Safe
            window.location.href = '/safe';
        }
    }, [txResult]);

    const renderContractData = (label: string, data: any, isLoading: boolean, isError: boolean) => {
        if (isLoading) return <p className='font-bold'>Loading {label}...</p>;
        if (isError || !data) return <p>Error loading {label}</p>;
        return <div className="flex justify-between w-full text-center place-self-center">
            <p>{label}</p>
            <AddresScaffold address={data.toString()} />
        </div>;
    };

    const openModal = () => {
        (document.getElementById('addr') as HTMLDialogElement).showModal();
    }

    return (
        <div className="m-10 grid">
            <MetaHeader title="Loan Manager | GhoSafe Protocol" />

            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Loan Manager</h1>
                <AddresScaffold address={safeAddress as string} format='long' size='xl' />
            </div>

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

                <div className="grid items-center my-2 rounded-md shadow-mdn mt-10 text-center">
                    <h2 className="text-2xl font-bold mb-10 text-center">Configure Loan Parameters</h2>
                    <div className="justify-center">
                        <p className="text-sm">Loan Duration Max (in Sec) </p>
                        <input type="number" value={loanDurationMax} onChange={(event) => setLoanDurationMax(Number(event.target.value))} className="input input-bordered input-primary w-full max-w-xs" />

                        <p className="text-sm">Loan Interest Rate (in BPS)</p>
                        <input type="number" value={loanInterestRate} onChange={(event) => setLoanInterestRate(Number(event.target.value))} className="input input-bordered input-primary w-full max-w-xs" />

                        <p className="text-sm">Total Borrow Power Available (in %)</p>
                        <input type="number" value={totalBorrowPowerAvailable} onChange={(event) => setTotalBorrowPowerAvailable(Number(event.target.value))} className="input input-bordered input-primary w-full max-w-xs" />

                        <p className="text-sm">Max Borrow Power Per User (in %)</p>
                        <input type="number" value={maxBorrowPowerPerUser} onChange={(event) => setMaxBorrowPowerPerUser(Number(event.target.value))} className="input input-bordered input-primary w-full max-w-xs" />
                    </div>

                    <button className="btn btn-primary mt-10 w-1/3 place-self-center" disabled={isLoading} onClick={handleWrite}>
                        {isLoading && <span className="loading loading-spinner loading-xs"></span>}
                        Send Transaction
                    </button>
                </div>
            </div>
            <WalletNotConnectedModal />
            <WrongChainModal goodChain="Sepolia" />
        </div>
    );
};

export default LoanManager;

