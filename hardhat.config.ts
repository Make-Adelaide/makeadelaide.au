
import "@nomiclabs/hardhat-waffle";

import "@nomiclabs/hardhat-vyper";

module.exports = {
  solidity: "0.8.16",
  vyper: {
    version: "0.3.7"
  },
  docgen: {
    except: [`Interface`, `openzeppelin`],
  },
  dependencyCompiler: {
    paths: [
      "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol",
      "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol"
    ]
  }
};
