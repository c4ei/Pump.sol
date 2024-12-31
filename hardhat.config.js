require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require('dotenv').config();
const { PRIVATE_KEY, INFURA_PROJECT_ID } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    AAH: {
      url: "https://rpc.c4ex.net",
      accounts: [`0x${PRIVATE_KEY}`]
      // ,gas: 5000000, // 가스 한도
      // gasPrice: 1000000000 // 가스 가격 (예: 1 gwei)
    },
    C4EI: {
      url: "https://rpc.c4ei.net",
      accounts: [`0x${PRIVATE_KEY}`]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};
