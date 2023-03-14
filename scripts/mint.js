/*
  You can use this script to quickly manually mintNFTs. To do so:
  Run `truffle exec ./scripts/mint.js`
  If you want to mint more than one NFT, just pass in the number
 */
var Adoretheall = artifacts.require("./Adoretheall.sol");

function getErrorMessage(error) {
  if (error instanceof Error) return error.message
  return String(error)
}

const main = async (cb) => {
  try {
    const args = process.argv.slice(4);
    const numNfts = args.length != 0 ? parseInt(args[0]) : 1;
    const Adoretheall = await Adoretheall.deployed();
    const PRICE = await Adoretheall.PRICE();
    const txn = await Adoretheall.mintNFTs(numNfts, {value: numNfts * parseInt(PRICE.toString())});
    console.log(txn);
  } catch(err) {
    console.log('Doh! ', getErrorMessage(err));
  }
  cb();
}

module.exports = main;