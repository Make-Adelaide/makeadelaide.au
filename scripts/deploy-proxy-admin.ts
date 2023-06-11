
import { ethers } from "hardhat";

import { getEnvAddr } from "./utils";

const EnvOwnerAddr = "MADL_OWNER_ADDR";

const main = async (ownerAddr: string) => {
  const factory = await ethers.getContractFactory("ProxyAdmin");
  const [rootSigner] = await ethers.getSigners(); // assumed to be in use for deploy
  console.log(`rootSigner: ${await rootSigner.getAddress()}`);
  const proxyAdmin = await factory.deploy();
  console.log(`proxy admin: ${proxyAdmin.address} with signer ${await rootSigner.getAddress()} deployed, changing owner...`);
  await proxyAdmin.transferOwnership(ownerAddr);
  console.log(`proxy admin ${proxyAdmin.address} changed to owner ${ownerAddr}`);
};

main(getEnvAddr(EnvOwnerAddr)).then(_ => {});
