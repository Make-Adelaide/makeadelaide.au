
import * as hre from "hardhat";

import { getEnv } from "./utils";

const EnvProxyAdminAddr = "MADL_PROXY_ADMIN_ADDR";
const EnvNewOwner = "MADL_NEW_OWNER_ADDR";

const main = async (proxyAdminAddr: string, newOwnerAddr: string) => {
  const proxyAdmin = await hre.ethers.getContractAt("ProxyAdmin", ownerAddr);
  await proxyAdmin.transferOwnership(newOwnerAddr);
  console.log(`proxy admin ${proxyAdmin.address} ownership changed to ${newOwnerAddr}`);
};

main(
  getEnv(EnvProxyAdminAddr),
  getEnv(EnvOwnerAddr)
).then(_ => {});
