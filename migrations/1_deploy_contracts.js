var Adoretheall = artifacts.require("./Adoretheall.sol");

module.exports = function(deployer) {
  deployer.deploy(Adoretheall,"BASEURL","HIDDENURL","Adoretheall","ATA");
};
