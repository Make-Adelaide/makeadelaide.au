
import * as hre from "hardhat";

import { ethers } from "ethers";

import { BigNumber } from "ethers";

export const getEnv = (name: string): string => {
  const v = process.env[name];
  if (v == undefined || v == "") throw new Error(`env ${name} not set!`);
  return v;
};

export const getEnvAddr = (name: string): string =>
  ethers.utils.getAddress(getEnv(name));

export const getEnvBigNumber = (name: string): BigNumber =>
  BigNumber.from(getEnv(name));

export const deployTransparentProxy = async (
  proxyAdminAddr: string,
  underlyingFactory: ethers.ContractFactory,
  initFunctionName: string,
  ...initArgs: any[]
): Promise<[ethers.Contract, ethers.Contract]> => {
  const transparentProxyFactory = await hre.ethers.getContractFactory(
    "TransparentUpgradeableProxy"
  );
  const initData = underlyingFactory.interface.encodeFunctionData(
    initFunctionName,
    initArgs
  );
  const impl = await underlyingFactory.deploy();
  const proxy = await transparentProxyFactory.deploy(
    impl.address, // "logic" contract
    proxyAdminAddr, // owner contract
    initData
  );
  return[proxy, impl];
};
