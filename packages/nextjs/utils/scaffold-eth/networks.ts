import * as chains from "viem/chains";
import scaffoldConfig from "~~/scaffold.config";


type TokenData = {
  symbol: string;
  name: string;
  address: string;
  decimal: number;
  logoURI: string;
};

type ChainAttributes = {
  color: string | [string, string];  // color or [lightThemeColor, darkThemeColor]
  nativeCurrencyTokenAddress?: string;  // Used for networks with non-ETH native currency
  tokens?: Record<string, TokenData>;  // Tokens specific to the chain
  aTokens?: Record<string, TokenData>;  // aTokens specific to the chain
  ghoTokens?: Record<string, TokenData>;  // ghoTokens specific to the chain
};

export type ChainWithAttributes = chains.Chain & Partial<ChainAttributes>;

export const NETWORKS_EXTRA_DATA: Record<string, ChainAttributes> = {
  [chains.hardhat.id]: {
    color: "#b8af0c",
  },
  [chains.mainnet.id]: {
    color: "#ff8b9e",
  },
  [chains.sepolia.id]: {
    color: ["#5f4bb6", "#87ff65"],
    aTokens: {
      "aAAVE": {
        symbol: "aAAVE",
        name: "aAave",
        address: "0x6b8558764d3b7572136F17174Cb9aB1DDc7E1259",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/aave.svg"
      },
      "aUSDC": {
        symbol: "aUSDC",
        name: "Aave Interest bearing USDC",
        address: "0x16dA4541aD1807f4443d92D26044C1147406EB80",
        decimal: 6,
        "logoURI": "https://app.aave.com/icons/tokens/usdc.svg"
      },
      "aDAI": {
        symbol: "aDAI",
        name: "Aave Interest bearing DAI",
        address: "0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/dai.svg"
      },
      "aUSDT": {
        symbol: "aUSDT",
        name: "Aave Interest bearing USDT",
        address: "0xAF0F6e8b0Dc5c913bbF4d14c22B4E78Dd14310B6",
        decimal: 6,
        "logoURI": "https://app.aave.com/icons/tokens/usdt.svg"
      },
      "aWBTC": {
        symbol: "aWBTC",
        name: "Aave Interest bearing WBTC",
        address: "0x1804Bf30507dc2EB3bDEbbbdd859991EAeF6EefF",
        decimal: 8,
        "logoURI": "https://app.aave.com/icons/tokens/wbtc.svg"
      },
      "aWETH": {
        symbol: "aWETH",
        name: "Aave Interest bearing WETH",
        address: "0x5b071b590a59395fE4025A0Ccc1FcC931AAc1830",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/weth.svg"
      },
      "aLINK": {
        symbol: "aLINK",
        name: "Aave Interest bearing LINK",
        address: "0x3FfAf50D4F4E96eB78f2407c090b72e86eCaed24",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/link.svg"
      }
    },
    ghoTokens: {
      "gho": {
        symbol: "GHO",
        name: "Gho Token",
        address: "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/gho.svg"
      },
      "debtGho": {
        symbol: "variableDebtSepGHO",
        name: "Variable Debt Gho Token",
        address: "0x67ae46EF043F7A4508BD1d6B94DB6c33F0915844",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/gho.svg"
      }
    },
    tokens: {
      "AAVE": {
        symbol: "AAVE",
        name: "Aave",
        address: "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/aave.svg"
      },
      "usdc": {
        symbol: "USDC",
        name: "USDC",
        address: "0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8",
        decimal: 6,
        "logoURI": "https://app.aave.com/icons/tokens/usdc.svg"
      },
      "dai": {
        symbol: "DAI",
        name: "DAI",
        address: "0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/dai.svg"
      },
      "usdt": {
        symbol: "USDT",
        name: "Tether",
        address: "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0",
        decimal: 6,
        "logoURI": "https://app.aave.com/icons/tokens/usdt.svg"
      },
      "wbtc": {
        symbol: "WBTC",
        name: "Wrapped Bitcoin",
        address: "0x29f2D40B0605204364af54EC677bD022dA425d03",
        decimal: 8,
        "logoURI": "https://app.aave.com/icons/tokens/wbtc.svg"
      },
      "weth": {
        symbol: "WETH",
        name: "Wrapped Ether",
        address: "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/weth.svg"
      },
      "eth": {
        symbol: "ETH",
        name: "Ether",
        address: "0x0000000000000000000000000000000000000000",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/eth.svg"
      },
      "link": {
        symbol: "LINK",
        name: "ChainLink",
        address: "0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5",
        decimal: 18,
        "logoURI": "https://app.aave.com/icons/tokens/link.svg"
      }
    }
  },
  [chains.goerli.id]: {
    color: "#0975F6",
  },
  [chains.gnosis.id]: {
    color: "#48a9a6",
  },
  [chains.polygon.id]: {
    color: "#2bbdf7",
    nativeCurrencyTokenAddress: "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0",
  },
  [chains.polygonMumbai.id]: {
    color: "#92D9FA",
    nativeCurrencyTokenAddress: "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0",
  },
  [chains.optimismGoerli.id]: {
    color: "#f01a37",
  },
  [chains.optimism.id]: {
    color: "#f01a37",
  },
  [chains.arbitrumGoerli.id]: {
    color: "#28a0f0",
  },
  [chains.arbitrum.id]: {
    color: "#28a0f0",
  },
  [chains.fantom.id]: {
    color: "#1969ff",
  },
  [chains.fantomTestnet.id]: {
    color: "#1969ff",
  },
  [chains.scrollSepolia.id]: {
    color: "#fbebd4",
  },
};

/**
 * Gives the block explorer transaction URL, returns empty string if the network is a local chain
 */
export function getBlockExplorerTxLink(chainId: number, txnHash: string) {
  const chainNames = Object.keys(chains);

  const targetChainArr = chainNames.filter(chainName => {
    const wagmiChain = chains[chainName as keyof typeof chains];
    return wagmiChain.id === chainId;
  });

  if (targetChainArr.length === 0) {
    return "";
  }

  const targetChain = targetChainArr[0] as keyof typeof chains;
  // @ts-expect-error : ignoring error since `blockExplorers` key may or may not be present on some chains
  const blockExplorerTxURL = chains[targetChain]?.blockExplorers?.default?.url;

  if (!blockExplorerTxURL) {
    return "";
  }

  return `${blockExplorerTxURL}/tx/${txnHash}`;
}

/**
 * Gives the block explorer URL for a given address.
 * Defaults to Etherscan if no (wagmi) block explorer is configured for the network.
 */
export function getBlockExplorerAddressLink(network: chains.Chain, address: string) {
  const blockExplorerBaseURL = network.blockExplorers?.default?.url;
  if (network.id === chains.hardhat.id) {
    return `/blockexplorer/address/${address}`;
  }

  if (!blockExplorerBaseURL) {
    return `https://etherscan.io/address/${address}`;
  }

  return `${blockExplorerBaseURL}/address/${address}`;
}

/**
 * @returns targetNetworks array containing networks configured in scaffold.config including extra network metadata
 */
export function getTargetNetworks(): ChainWithAttributes[] {
  return scaffoldConfig.targetNetworks.map(targetNetwork => ({
    ...targetNetwork,
    ...NETWORKS_EXTRA_DATA[targetNetwork.id],
  }));
}
