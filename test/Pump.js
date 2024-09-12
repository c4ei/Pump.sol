const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MemeTokenFactory", function () {
  let memeTokenFactory, MemeTokenFactory, MemeToken, owner, addr1, addr2;

  before(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    MemeTokenFactory = await ethers.getContractFactory("MemeTokenFactory");
    memeTokenFactory = await MemeTokenFactory.deploy();
  });

  describe("Deployment", function () {
    it("Should deploy MemeTokenFactory contract", async function () {
      expect(await memeTokenFactory.getAddress()).to.properAddress;
    });
  });

  describe("Creating a MemeToken", function () {
    let tokenAddress;

    it("Should create a MemeToken successfully", async function () {
      const createTx = await memeTokenFactory.createToken(
        "MemeToken",
        "MEME",
        "A fun token",
        "ipfs://image",
        "@twitter",
        "@telegram",
        "https://website.com"
      );
      const receipt = await createTx.wait();
      expect(receipt.status).to.eq(1);
    });

    it("Should store deployed token addresses", async function () {
      const deployedTokens = await memeTokenFactory.getDeployedTokens();
      expect(deployedTokens.length).to.equal(1);
      expect(deployedTokens[0]).to.properAddress;
    });
  });

  describe("MemeToken Interaction", function () {
    let memeToken;

    before(async () => {
      memeToken = await ethers.getContractAt("MemeToken", await memeTokenFactory.deployedTokens(0));
    });

    it("Should have a max supply of 1,000,000 MEME tokens", async function () {
      const totalSupply = await memeToken.totalSupply();
      expect(totalSupply).to.equal(ethers.parseUnits("1000000", 18));
    });

    it("Should allow users to buy tokens", async function () {
      const ethToSend = ethers.parseUnits("1", "ether");
      await memeToken.connect(addr1).buyTokens({ value: ethToSend });
      const balance = await memeToken.balanceOf(addr1.address);
      expect(balance).to.be.greaterThan(0);
    });

    it("Should allow users to sell tokens", async function () {
      const tokenAmountToSell = await memeToken.balanceOf(addr1.address);
      await memeToken.connect(addr1).approve(await memeToken.getAddress(), tokenAmountToSell);
      const initialEthBalance = await ethers.provider.getBalance(addr1.address);
      await memeToken.connect(addr1).sellTokens(tokenAmountToSell);
      const finalEthBalance = await ethers.provider.getBalance(addr1.address);
      expect(finalEthBalance).to.be.gt(initialEthBalance);
    });

    it("Should not allow buying with less than 1 wei", async function () {
      await expect(memeToken.connect(addr2).buyTokens({ value: 1 }))
        .to.be.revertedWith("send some ETH");
    });

    it("Should not allow selling more tokens than owned", async function () {
      await expect(memeToken.connect(addr2).sellTokens(ethers.parseUnits("100", 18)))
        .to.be.revertedWith("too poor");
    });

    it("Should allow users to pump", async function () {
      const ethToSend = ethers.parseUnits("1", "ether");
      for (let i = 0; i < 100; i++) {
        await memeToken.connect(addr1).buyTokens({ value: ethToSend });
      }
      const balance = await memeToken.balanceOf(addr1.address);
      expect(balance).to.be.greaterThan(0);
    });
  });
});
