import { getDefaultConfig } from "connectkit";
import { createConfig } from "wagmi"
import { getTargetNetworks } from "~~/utils/scaffold-eth";

const targetNetworks = getTargetNetworks();

export const wagmiConfig = createConfig(
  getDefaultConfig({
    // Required API Keys
    alchemyId: process.env.ALCHEMY_ID, // or infuraId
    walletConnectProjectId: process.env.WALLETCONNECT_PROJECT_ID || "",

    chains: targetNetworks,

    // Required
    appName: "GhoSafe",
  }),
);
