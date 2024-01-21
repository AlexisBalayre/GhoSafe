import * as chains from "viem/chains";

type ChainAttributes = {
    apiEndpoint: string;
    exchangeProxyAddress: string;
}

export type ChainWithAttributes = chains.Chain & Partial<ChainAttributes>;

export const NETWORKS_EXTRA_DATA: Record<string, ChainAttributes> = {
    [chains.sepolia.id]: {
        apiEndpoint: "https://sepolia.api.0x.org/",
        exchangeProxyAddress: "0xdef1c0ded9bec7f1a1670819833240f027b25eff",
    },
    [chains.polygonMumbai.id]: {
        apiEndpoint: "https://mumbai.api.0x.org/",
        exchangeProxyAddress: "0xf471d32cb40837bf24529fcf17418fc1a4807626",
    },
};

