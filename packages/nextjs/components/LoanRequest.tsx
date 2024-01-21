import React from 'react';

export interface LoanRequestProps {
    amountToBorrow: number;
    loanDuration: number;
    collateralAmountOrId: number;
    collateralAddress: string;
    borrower: string;
    collateralChainId: number;
    collateralType: 'NFT' | 'ERC20';
    loanRequestId?: number;
}

const LoanRequest: React.FC<LoanRequestProps> = ({
    loanRequestId,
    amountToBorrow,
    loanDuration,
    collateralAmountOrId,
    collateralAddress,
    borrower,
    collateralChainId,
    collateralType
}) => {
    return (
        <div className="card bg-base-100 shadow-xl">
            <div className="card-body">
                <h2 className="card-title">Loan Request {loanRequestId}</h2>
                <p>GHO Amount Requested: {amountToBorrow}</p>
                <p>Loan Duration: {loanDuration}</p>
                <p>Collateral Type: {collateralType}</p>
                <p>Collateral Address: {collateralAddress}</p>
                {collateralType === 'NFT' ? <p>Collateral ID: {collateralAmountOrId}</p> : <p>Collateral Amount: {collateralAmountOrId}</p>}
                <p>Collateral Chain ID: {collateralChainId}</p>
                <p>Borrower: {borrower}</p>
            </div>
            <button className="btn btn-primary" onClick={() => window.location.href = `/loanRequests/${loanRequestId}`}>Authorize Loan</button>
        </div>
    );
};

export default LoanRequest;
