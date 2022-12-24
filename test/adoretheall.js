const Adoretheall = artifacts.require("./Adoretheall.sol");

contract("Adoretheall", accounts => {

  let AdoretheallInstance;

  beforeEach(async () => {
    AdoretheallInstance = await Adoretheall.deployed();
  });

  it("... should return setBaseURI", async () => {
    const baseUrl = await AdoretheallInstance._baseURI();
    assert.equal(baseUrl,"HIDDENURL", "return not hiddenCid")
    const baseUrlChange = await AdoretheallInstance.setBlindBoxOpened(true);
    console.log(baseUrlChange);
    alert(baseUrlChange);
    const baseUrlChanged = await AdoretheallInstance._baseURI();
    assert.equal(baseUrl,"BASEURL", "return not cid")
  })
  
  xcontext("... mint single nft",async () => {
    it("mint a token", async () => {

    })
  })

  xcontext("... mint nfts",async () => {
    it("mint tokens", async () => {
      //Time Travelling
      await time.increase(time.duration.days(1));
    })
  })
});
