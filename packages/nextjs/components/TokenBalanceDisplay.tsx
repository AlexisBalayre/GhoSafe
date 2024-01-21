import React, { useState, useEffect } from 'react';
import { useBalance } from 'wagmi';
import { AddressV2 } from './scaffold-eth';

export const TokenBalanceDisplay = ({ address, tokenAddress, tokenSymbol, logoUrl }: { address: string, tokenAddress: string, tokenSymbol: string, logoUrl: string }) => {
    const [balance, setBalance] = useState("0");

    const params = tokenSymbol == "ETH" ? { address: address } : { address: address, token: tokenAddress };

    const { data } = useBalance(params);

    const [isClient, setIsClient] = useState(false)

    useEffect(() => {
        if (data && data.formatted) {
            const balance = data.formatted?.toString() || "0";
            setBalance(balance);
        }
        setIsClient(true)
    }, [data]);

    if (!isClient) {
        return null
    } else {
        return (
            <div className="flex flex-row items-center justify-between w-full p-4 my-2 bg-base-300 rounded-md shadow-md">
                <div className="flex flex-row items-center">
                    <img className="w-8 h-8 rounded-full" src={logoUrl} />
                    <span className="text-sm font-bold ml-5">{tokenSymbol}</span>
                    <span className='ml-5'><AddressV2 address={tokenAddress} format='long' size='xs' /></span>
                </div>
                <div className="flex flex-col items-end">
                    <span className="text-sm font-bold">{balance}</span>
                </div>
            </div>
        );
    }
};
