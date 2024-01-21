
import React, { useState, useEffect } from 'react';
import type { NextPage } from "next";
import { useContractRead,usePublicClient, useWalletClient, useNetwork } from 'wagmi';
import LoanRequest, { LoanRequestProps } from '../../components/LoanRequest';
import { MetaHeader } from '../../components/MetaHeader';
import { Address as AddresScaffold } from "~~/components/scaffold-eth";
import safeABI from '../../../hardhat/artifacts/contracts/Sepolia/users/SafeSepolia.sol/SafeSepolia.json';
import loanManagerABI from '../../../hardhat/artifacts/contracts/Sepolia/users/LoanManagerSepolia.sol/LoanManagerSepolia.json';
import mailboxABI from '../../../hardhat/artifacts/contracts/Sepolia/users/MailboxSepolia.sol/MailboxSepolia.json';
import { DocumentArrowDownIcon } from '@heroicons/react/24/outline';
import { WalletNotConnectedModal } from '~~/components/WalletNotConnectedModal';
import { WrongChainModal } from '~~/components/WrongChainModal';

const LoanRequests: NextPage = () => {
    const [safeAddress, setSafeAddress] = useState('')

    const [loanRequests, setLoanRequests] = useState([] as LoanRequestProps[]);

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

    const publicClient = usePublicClient();
    const getLoanRequests = async () => {
        const loanRequests: LoanRequestProps[] = [];

        // Get block number
        const blockNumber = await publicClient.getBlockNumber();

        // Create filter
        const logs = await publicClient.getContractEvents({
            address: '0x93446087674906C8d8CEcBfC17fCFCe6E59551D6',
            abi: mailboxABI.abi,
            eventName: 'LoanRequestCreated',
            fromBlock: 5116342n,
            toBlock: blockNumber,
        })
        // Parse events
        logs.forEach(async (log) => {
            loanRequests.push({
                loanRequestId: parseInt((log as any)?.args?.loanRequestId),
                amountToBorrow: parseInt((log as any)?.args?.amountToBorrow),
                loanDuration: parseInt((log as any)?.args?.loanDuration),
                collateralAmountOrId: parseInt((log as any)?.args?.collateralAmountOrId),
                collateralAddress: (log as any)?.args?.collateralAddress,
                borrower: (log as any)?.args?.borrower,
                collateralChainId: parseInt((log as any)?.args?.collateralChainId),
                collateralType: (log as any)?.args?.collateralType === false ? 'NFT' : 'ERC20',
            });
        });

        setLoanRequests(loanRequests);
    }

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
        getLoanRequests();
    },
        // [txResult]
    );

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
            <MetaHeader title="Loan Requests | GhoSafe Protocol" />

            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Loan Requests</h1>
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

                <div className="grid items-center my-2 rounded-md shadow-mdn mt-10 text-center">
                    <h2 className="text-2xl font-bold mb-10 text-center">Last Requests</h2>
                    <div>
                        {loanRequests.map((request, index) => (
                            <div className='pb-20'  key={index}>
                                <LoanRequest {...request} />
                            </div>
                        ))}
                    </div>
                </div>
            </div>
            <WalletNotConnectedModal />
            <WrongChainModal goodChain="Sepolia" />
        </div>
    );
};

export default LoanRequests;

