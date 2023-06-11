
import * as hre from "hardhat";

import { getEnvAddr } from "./utils";

const EnvOperatorAddr = "MADL_TOKEN_OPERATOR_ADDR";

const main = async (operatorAddr: string) => {
  const factory = await hre.ethers.getContractFactory("MadlToken");
  const token = await factory.deploy(operatorAddr);
  console.log(`deployed token to ${token.address} with distributor ${operatorAddr}`);
};

main(getEnvAddr(EnvOperatorAddr)).then(_ => {});
