
import * as hre from "hardhat";

import { getEnvAddr, deployTransparentProxy } from "./utils";

const EnvProxyAdminAddr = "MADL_DAO_PROXY_ADMIN_ADDR";
const EnvEmergencyCouncil = "MADL_DAO_EMERGENCY_ADMIN";
const EnvTokenAddr = "MADL_DAO_TOKEN_ADDR";

const main = async (
  proxyAdminAddr: string,
  emergencyCouncilAddr: string,
  tokenAddr: string
) => {
  const [rootSigner ] = await hre.ethers.getSigners();

  const factory = await hre.ethers.getContractFactory("DAO");

  const [proxy, impl] = await deployTransparentProxy(
    proxyAdminAddr, // admin for ownership of the proxy
    factory, // factory for the impl for the impl deployment
    "initialise", // function to use for initialisation
    emergencyCouncilAddr,
    tokenAddr
  );

  console.log(`deployed dao impl to ${impl.address}`);

  console.log(`deployed dao proxy to ${proxy.address}, with signer ${await rootSigner.getAddress()}, args ${[
    emergencyCouncilAddr,
    tokenAddr
  ]}`);
};

main(
  getEnvAddr(EnvProxyAdminAddr),
  getEnvAddr(EnvEmergencyCouncil),
  getEnvAddr(EnvTokenAddr)
).then(_ => {});
