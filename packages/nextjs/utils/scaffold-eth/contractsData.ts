import scaffoldConfig from "~~/scaffold.config";
import { contracts } from "~~/utils/scaffold-eth/contract";

export function getAllContracts(chainId: number) {
  const contractsData = contracts?.[scaffoldConfig.targetNetworks[chainId === 11155111 ? 0 : 1].id];
  return contractsData ? contractsData : {};
}
