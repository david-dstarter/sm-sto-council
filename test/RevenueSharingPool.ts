import { ethers } from "hardhat";
import { Contract } from "ethers";
import { expect } from "chai";

describe("RevenueSharingPool", function () {
    let pool: any;
    let owner: any;
    let user: any;
    let token1: any;
    let token2: any;
    let token3: any;
    let token4: any;
    let token5: any;
    let token6: any;
    let token7: any;
    let token8: any;
    let token9: any;
    let token10: any;


    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();
        const Pool = await ethers.getContractFactory("RevenueSharingPool");
        pool = await Pool.connect(owner).deploy()
        const ERC20Mock = await ethers.getContractFactory("U2UToken");
        token1 = await ERC20Mock.connect(owner).deploy('U2V1', 'U2V1');
        token2 = await ERC20Mock.connect(owner).deploy('U2V2', 'U2V2');
        token3 = await ERC20Mock.connect(owner).deploy('U2V3', 'U2V3');
        token4 = await ERC20Mock.connect(owner).deploy('U2V4', 'U2V4');
        token5 = await ERC20Mock.connect(owner).deploy('U2V5', 'U2V5');
        token6 = await ERC20Mock.connect(owner).deploy('U2V6', 'U2V6');
        token7 = await ERC20Mock.connect(owner).deploy('U2V7', 'U2V7');
        token8 = await ERC20Mock.connect(owner).deploy('U2V8', 'U2V8');
        token9 = await ERC20Mock.connect(owner).deploy('U2V9', 'U2V9');
        token10 = await ERC20Mock.connect(owner).deploy('U2V10', 'U2V10');

    });

    it("should transfer tokens to the pool", async function () {

        await pool.connect(owner).setTokenlist(token1)
        await pool.connect(owner).setTokenlist(token2)
        await pool.connect(owner).setTokenlist(token3)
        await pool.connect(owner).setTokenlist(token4)
        await pool.connect(owner).setTokenlist(token5)
        await pool.connect(owner).setTokenlist(token6)
        await pool.connect(owner).setTokenlist(token7)
        await pool.connect(owner).setTokenlist(token8)
        await pool.connect(owner).setTokenlist(token9)
        await pool.connect(owner).setTokenlist(token10)

        const projectId = "Project_1";
        const id = "21c5d220-9543-4d59-98bc-71c92db1df29";
        const amount = ethers.parseEther('20');
        const intiAmount = ethers.parseEther('200');
        await token1.mint(user.address, intiAmount );
        await token1.connect(user).approve(pool, amount);
        const result = await pool.connect(user).transferTokenToPool(id, projectId, token1, amount);
        const tx = await result.wait();
        expect(await token1.balanceOf(pool)).to.equal(amount);
        // const recipient = await pool.recipients(projectId, token);
        const claim = await pool.revenueClaimable(id, user.address);
        console.log(claim)

    });
});