
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-vyper";

import "@nomicfoundation/hardhat-verify";

import "hardhat-dependency-compiler";

import type { HardhatUserConfig } from "hardhat/types";

const networks: HardhatUserConfig['networks'] = {};

if (process.env.MADL_DEPLOY_OPTIMISM_KEY)
  networks["optimism"] = {
    accounts: [process.env.MADL_DEPLOY_OPTIMISM_KEY],
    url: process.env.MADL_DEPLOY_OPTIMISM_URL
  };

module.exports = {
  solidity: "0.8.16",
  networks,
  dependencyCompiler: {
    paths: [
      "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol",
      "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol"
    ]
  },
  apiKey: {
    optimisticEthereum: process.env.MADL_OPTIMISM_SCAN_KEY
  }
};
