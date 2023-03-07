const Adoretheall = artifacts.require("./Adoretheall.sol");

contract("Adoretheall", accounts => {

  let AdoretheallInstance;

  beforeEach(async () => {
    AdoretheallInstance = await Adoretheall.deployed();
  });

  it("... should return baseTokenURI", async () => {
    const baseTokenURI = await AdoretheallInstance.baseTokenURI;
    assert.equal(baseUrl,"baseTokenURI", "return not baseTokenURI")
  });

  it("mint tokens", async () => {
    const result = await AdoretheallInstance.mintNFTs(1);
  });
});
