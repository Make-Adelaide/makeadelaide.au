
import * as hre from "hardhat";

import { getEnvAddr, deployTransparentProxy } from "./utils";

const EnvProxyAdmin = "MADL_DISTRIBUTION_PROXY_ADMIN";
const EnvOperator = "MADL_DISTRIBUTION_OPERATOR";
const EnvTokenAddr = "MADL_DISTRIBUTION_TOKEN_ADDR";

const main = async (
  proxyAdminAddr: string,
  operatorAddr: string,
  tokenAddr: string
) => {
  const [rootSigner ] = await hre.ethers.getSigners();

  const factory = await hre.ethers.getContractFactory("DAO");

  const [proxy, impl] = await deployTransparentProxy(
    proxyAdminAddr, // admin for ownership of the proxy
    factory, // factory for the impl for the impl deployment
    "initialise", // function to use for initialisation
    operatorAddr,
    tokenAddr
  );

  console.log(`deployed distribution impl to ${impl.address}`);

  console.log(`deployed distribution proxy to ${proxy.address}, with signer ${await rootSigner.getAddress()}, args ${[
    operatorAddr,
    tokenAddr
  ]}`);
};

main(
  getEnvAddr(EnvProxyAdmin),
  getEnvAddr(EnvOperator),
  getEnvAddr(EnvTokenAddr)
).then(_ => {});
