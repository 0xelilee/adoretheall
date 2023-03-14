var Adoretheall = artifacts.require("./adoretheall.sol");

module.exports = function(deployer) {
  deployer.deploy(Adoretheall,process.env.BASEURI,"Adoretheall","ATA");
};
