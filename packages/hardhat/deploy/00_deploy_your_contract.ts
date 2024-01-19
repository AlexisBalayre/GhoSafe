import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Deploy GhoSafeAccessManager
  /* await deploy("GhoSafeAccessManagerSepolia", {
    from: deployer,
    log: true,
    autoMine: true,
  });
  const ghosafeAccessManagerSepolia = await hre.ethers.getContract("GhoSafeAccessManagerSepolia", deployer);

  // Deploy GhoSafeID
  const name = "GhoSafeID";
  const symbol = "GSID";
  await deploy("GhoSafeIDSepolia", {
    args: [
      name,
      symbol,
      ghosafeAccessManagerSepolia.address
    ],
    from: deployer,
    log: true,
    autoMine: true,
  });
  const ghosafeIDSepolia = await hre.ethers.getContract("GhoSafeIDSepolia", deployer);

  // Deploy GhoSafeLoanAdvertisementBook
  await deploy("GhoSafeLoanAdvertisementBookSepolia", {
    args: [
      ghosafeAccessManagerSepolia.address
    ],
    from: deployer,
    log: true,
    autoMine: true,
  });
  const ghosafeLoanAdvertisementBookSepolia = await hre.ethers.getContract("GhoSafeLoanAdvertisementBookSepolia", deployer); */

  /* // Deploy Safe
  await deploy("SafeSepolia", {
    args: [
      0,
      "0x77D08C620728194fF1A4b3dA458f04975568CF1e",
      "0x8E3cDEA3e6e439a49c7958d0bB76254E786b5266",
      "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59", // Router
      "0x779877A7B0D9E8603169DdbD7836e478b4624789", // Link
    ],
    from: deployer,
    log: true,
    autoMine: true,
  }); */

  await deploy("BoredApeYachtClub", {
    from: deployer,
    log: true,
    autoMine: true,
  });

  /* await deploy("LoanSafeMumbai", {
    args: [
      "0x1035CabC275068e0F4b745A29CEDf38E13aF41b1",
      "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
    ],
    from: deployer,
    log: true,
    autoMine: true,
  }); */

  // Get the deployed contract
  // const yourContract = await hre.ethers.getContract("YourContract", deployer);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["ContractsDeployment"];
