import * as hre from "hardhat";

import { getEnvAddr, deployTransparentProxy } from "./utils";

const EnvProxyAdminAddr = "MADL_WEBSITE_PROXY_ADMIN_ADDR";
const EnvOperatorAddr = "MADL_WEBSITE_OWNER";
const EnvSubmitterAddr = "MADL_WEBSITE_SUBMITTER";

const main = async (
  proxyAdminAddr: string,
  operatorAddr: string,
  submitterAddr: string
) => {
  const [rootSigner ] = await hre.ethers.getSigners();

  const factory = await hre.ethers.getContractFactory("DAO");

  const [proxy, impl] = await deployTransparentProxy(
    proxyAdminAddr, // admin for ownership of the proxy
    factory, // factory for the impl for the impl deployment
    "initialise", // function to use for initialisation
    operatorAddr,
    submitterAddr
  );

  console.log(`deployed website impl to ${impl.address}`);

  console.log(`deployed website proxy to ${proxy.address}, with signer ${await rootSigner.getAddress()}, args ${[
    operatorAddr,
    submitterAddr
  ]}`);
};

main(
  getEnvAddr(EnvProxyAdminAddr),
  getEnvAddr(EnvOperatorAddr),
  getEnvAddr(EnvSubmitterAddr)
).then(_ => {});
