const dotenv = require('dotenv').config()
const { readFileSync } = require('fs')
const path = require('path')
const { join } = require('path')
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    goerli: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://goerli.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: 5,
    },
    mainnet: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://mainnet.infura.io/v3'+ process.env.INFURA_API_KEY)
      },
      network_id: 1,
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.13"
    }
  },
  db: {
    enabled: false
  },

  //verify contract
  plugins: ['truffle-plugin-verify'],

  //config api_key
  api_keys: {
    etherscan: process.env.ADORETHEALL,
    optimistic_etherscan: process.env.INFURA_API_KEY,
    arbiscan: process.env.INFURA_API_KEY,
    bscscan: process.env.INFURA_API_KEY,
  }
};