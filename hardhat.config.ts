import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import ('dotenv/config')

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    }
  },
  networks: {
    bsctest: {
      url: process.env.BSC_TEST_URL || "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bscmainet: {
      url: process.env.BSC_MAINET_URL || "https://bsc-dataseed.binance.org",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.BSC_API_KEY || "SJQ9T5HK77GT8A4JVKEI2WBPCXN7T6JFSD"
  },

};

export default config;
