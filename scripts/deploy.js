const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Deploying AahTokenFactory contract...");

  const AahTokenFactory = await ethers.getContractFactory("AahTokenFactory");
  const aahTokenFactory = await upgrades.deployProxy(AahTokenFactory, [], {
    initializer: "initialize",
  });

  await aahTokenFactory.waitForDeployment();

  console.log("AahTokenFactory deployed to:", await aahTokenFactory.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
