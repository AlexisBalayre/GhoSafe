import { useEffect, useState } from "react";
import { useRouter } from "next/router";
import type { NextPage } from "next";
import { Hash } from "viem";
import { useContractRead, useContractWrite, useNetwork, useWaitForTransaction, useWalletClient } from 'wagmi';
import { Address as AddresScaffold, TxReceipt, getParsedError } from "~~/components/scaffold-eth";
import loanManagerABI from '../../../hardhat/artifacts/contracts/Sepolia/users/LoanManagerSepolia.sol/LoanManagerSepolia.json';
import safeABI from '../../../hardhat/artifacts/contracts/Sepolia/users/SafeSepolia.sol/SafeSepolia.json';
import mailboxABI from '../../../hardhat/artifacts/contracts/Sepolia/users/MailboxSepolia.sol/MailboxSepolia.json';
import ghoSafeIDABI from '../../../hardhat/artifacts/contracts/Sepolia/protocol/GhoSafeIDSepolia.sol/GhoSafeIDSepolia.json';
import { notification } from "~~/utils/scaffold-eth";
import CreditScore from "~~/components/CreditScore";
import { MetaHeader } from "~~/components/MetaHeader";
import { useTransactor } from "~~/hooks/scaffold-eth";
import { WalletNotConnectedModal } from '~~/components/WalletNotConnectedModal';
import { WrongChainModal } from '~~/components/WrongChainModal';

const LoanRequest: NextPage = () => {

  const router = useRouter();
  const [safeAddress, setSafeAddress] = useState('');
  const { loanRequestId } = router.query as { loanRequestId: Hash };
  const { data: walletClient } = useWalletClient();
  const { chain } = useNetwork();

  const { data: loanManager } = useContractRead({
    abi: safeABI.abi,
    address: safeAddress,
    functionName: "USER_LOAN_MANAGER_ADDRESS"
  });
  const { data: mailbox } = useContractRead({
    abi: safeABI.abi,
    address: safeAddress,
    functionName: "USER_MAILBOX_ADDRESS"
  });
  const { data: loanRequestData } = useContractRead({
    abi: mailboxABI.abi,
    address: mailbox?.toString(),
    functionName: "loanRequests",
    args: [loanRequestId]
  });
  const { data: ghoSafeId} = useContractRead({
    abi: ghoSafeIDABI.abi,
    address: "0x77D08C620728194fF1A4b3dA458f04975568CF1e",
    functionName: "ghoSafeIdOf",
    args: [loanRequestData ? (loanRequestData as any)[4] : null]
  });
  const { data: creditScoreData, isLoading: isLoadingCreditScore } = useContractRead({
    abi: ghoSafeIDABI.abi,
    address: "0x77D08C620728194fF1A4b3dA458f04975568CF1e",
    functionName: "creditScoreDataOf",
    args: [ghoSafeId?.toString()]
  })

  const {
    data: result,
    isLoading,
    writeAsync,
  } = useContractWrite({
    abi: loanManagerABI.abi,
    address: loanManager?.toString(),
    functionName: "authorizeLoan",
    args: [
      loanRequestId
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
  },
    [txResult]
  );

  interface CreditScoreData {
    loansCount: number;
    totalAmountBorrowed: number;
    totalAmountRepaid: number;
    creditScore: number;
  }

  return (
    <div className="m-10 grid">
      <MetaHeader title="Loan Requests | GhoSafe Protocol" />

      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Loan Request {loanRequestId}</h1>
        <AddresScaffold address={safeAddress as string} format='long' size='xl' />
      </div>

      {txResult ? (
        <div className="flex-grow basis-0">
          <TxReceipt txResult={txResult} />
        </div>
      ) : null}

      <div className="grid text-center mt-10">
        <div className="card bg-base-100 shadow-xl p-4">
          <div className="mt-4">

            <div>
              <p>Credit Score</p>
              {isLoadingCreditScore ? <p>Loading...</p> : <CreditScore score={(creditScoreData as CreditScoreData)?.creditScore} />}
            </div>

            <div className="stats stats-vertical lg:stats-horizontal shadow  m-10">
              <div className="stat">
                <div className="stat-title">Loans Count</div>
                <div className="stat-value">{(creditScoreData as CreditScoreData)?.loansCount + ""}</div>
              </div>

              <div className="stat">
                <div className="stat-title">Amount Borrowed</div>
                <div className="stat-value">{(creditScoreData as CreditScoreData)?.totalAmountBorrowed + ""}</div>
              </div>

              <div className="stat">
                <div className="stat-title">Amount Repaid</div>
                <div className="stat-value">{(creditScoreData as CreditScoreData)?.totalAmountRepaid + ""}</div>
              </div>

            </div>
          </div>

          <button className="btn btn-primary w-1/3 place-self-center m-10" disabled={isLoading} onClick={handleWrite}>
            {isLoading && <span className="loading loading-spinner loading-xs"></span>}
            Authorize Loan
          </button>

        </div>
      </div>
      <WalletNotConnectedModal />
      <WrongChainModal goodChain="Sepolia" />
    </div>
  );
};

export default LoanRequest;