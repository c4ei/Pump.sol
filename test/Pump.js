const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AahTokenFactory", function () {
  let aahTokenFactory, AahTokenFactory, AahToken, owner, addr1, addr2;

  before(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    AahTokenFactory = await ethers.getContractFactory("AahTokenFactory");
    aahTokenFactory = await AahTokenFactory.deploy();
  });

  describe("Deployment", function () {
    it("Should deploy AahTokenFactory contract", async function () {
      expect(await aahTokenFactory.getAddress()).to.properAddress;
    });
  });

  describe("Creating a AahToken", function () {
    let tokenAddress;

    it("Should create a AahToken successfully", async function () {
      const createTx = await aahTokenFactory.createToken(
        "AahFunToken",
        "AFT",
        "AAH blockchain fun token",
        "https://pump.mypinata.cloud/ipfs/QmeJT9QsJ1cw9SieM3acSuRxrFqCKk8N5uJH7J62yhNGyA",
        "@c4ei_net",
        "@c4eiAirdrop",
        // "https://x.com/c4ei_net",
        // "https://t.me/c4eiAirdrop",
        "https://c4ei.net"
      );
      const receipt = await createTx.wait();
      expect(receipt.status).to.eq(1);
    });

    it("Should store deployed token addresses", async function () {
      const deployedTokens = await aahTokenFactory.getDeployedTokens();
      expect(deployedTokens.length).to.equal(1);
      expect(deployedTokens[0]).to.properAddress;
    });
  });

  describe("AahToken Interaction", function () {
    let aahToken;

    before(async () => {
      aahToken = await ethers.getContractAt("AahToken", await aahTokenFactory.deployedTokens(0));
    });

    it("Should have a max supply of 1,000,000 AFT tokens", async function () {
      const totalSupply = await aahToken.totalSupply();
      expect(totalSupply).to.equal(ethers.parseUnits("1000000", 18));
    });

    it("Should allow users to buy tokens", async function () {
      const ethToSend = ethers.parseUnits("1", "ether");
      await aahToken.connect(addr1).buyTokens({ value: ethToSend });
      const balance = await aahToken.balanceOf(addr1.address);
      expect(balance).to.be.greaterThan(0);
    });

    it("Should allow users to sell tokens", async function () {
      const tokenAmountToSell = await aahToken.balanceOf(addr1.address);
      await aahToken.connect(addr1).approve(await aahToken.getAddress(), tokenAmountToSell);
      const initialEthBalance = await ethers.provider.getBalance(addr1.address);
      await aahToken.connect(addr1).sellTokens(tokenAmountToSell);
      const finalEthBalance = await ethers.provider.getBalance(addr1.address);
      expect(finalEthBalance).to.be.gt(initialEthBalance);
    });

    it("Should not allow buying with less than 1 wei", async function () {
      await expect(aahToken.connect(addr2).buyTokens({ value: 1 }))
        .to.be.revertedWith("send some ETH");
    });

    it("Should not allow selling more tokens than owned", async function () {
      await expect(aahToken.connect(addr2).sellTokens(ethers.parseUnits("100", 18)))
        .to.be.revertedWith("too poor");
    });

    it("Should allow users to pump", async function () {
      const ethToSend = ethers.parseUnits("1", "ether");
      for (let i = 0; i < 100; i++) {
        await aahToken.connect(addr1).buyTokens({ value: ethToSend });
      }
      const balance = await aahToken.balanceOf(addr1.address);
      expect(balance).to.be.greaterThan(0);
    });
  });
});
