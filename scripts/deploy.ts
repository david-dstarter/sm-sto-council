import { ethers } from "hardhat";

async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 60;
  //
  // const lockedAmount = ethers.parseEther("0.001");
  //
  // const lock = await ethers.deployContract("Lock", [unlockTime], {
  //   value: lockedAmount,
  // });
  //
  // await lock.waitForDeployment();
  //
  // console.log(
  //   `Lock with ${ethers.formatEther(
  //     lockedAmount
  //   )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  // );
  const name = 'U2V1';
  const symbol = 'U2V1';
  const totalSupply = 1000000000
  const revenuePool = await ethers.deployContract("RevenueSharingPool")
  // const erc20Mock = await ethers.deployContract("U2UToken", [name, symbol, totalSupply])

  await revenuePool.waitForDeployment();
  // await erc20Mock.waitForDeployment();
  console.log('Revenue pool addrress', revenuePool.target)
  // console.log(erc20Mock)
}

async function deployTokens() {
  for (let i = 1; i<=10; i++) {
    const name = `U2V${i}`;
    const symbol = `U2V${i}`;
    const erc20Mock = await ethers.deployContract("U2UToken", [name, symbol])
    await erc20Mock.waitForDeployment();
    console.log(name,erc20Mock.target)
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// deployTokens().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });