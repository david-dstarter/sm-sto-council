import { ethers } from "hardhat";
import { Contract } from "ethers";
import { expect } from "chai";

describe("RevenueSharingPool", function () {
    let pool: any;
    let owner: any;
    let user: any;
    let token: any;

    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();
        const Pool = await ethers.getContractFactory("RevenueSharingPool");
        pool = await Pool.connect(owner).deploy()
        const ERC20Mock = await ethers.getContractFactory("U2UToken");
        token = await ERC20Mock.connect(owner).deploy('U2U', 'U2U');
    });

    it("should transfer U2U to the pool", async function () {
        const projectId = "Project_1";

        const amount = ethers.toBigInt(10000);

        const tx = await owner.sendTransaction({
            to: pool.address,
            value: amount,
        });
        await tx.wait();
        const transferTx = await pool.transferToPool(projectId);
        await transferTx.wait();
        const expectedLastBlock = (await ethers.provider.getBlockNumber()) + 1;
        const lastBlock = await pool.lastBlockPerProject(projectId);
        expect(lastBlock).to.equal(expectedLastBlock);

        // const recipient = await pool.recipients(projectId, token);
    });

    it("should transfer tokens to the pool", async function () {
        const projectId = "Project_1";

        const mintBalance = ethers.toBigInt(10000);
        const initialBalance = ethers.toBigInt(100);
        await token.mint(user.address, mintBalance);
        await token.connect(user).approve(pool, initialBalance);

        const amount = ethers.toBigInt(20);

        const result = await pool.connect(user).transferTokenToPool('Project_1', token, amount.toString());
        const tx = await result.wait();
        expect(await token.balanceOf(pool)).to.equal(amount);
        // const recipient = await pool.recipients(projectId, token);
    });
});