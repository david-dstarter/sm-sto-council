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
        const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
        token = await ERC20Mock.connect(owner).deploy('Test', 'TTK', 18, 1000000000);
    });

    it("should add project", async function () {
        await pool.connect(owner).addProject("Project 1");
        await pool.connect(owner).addProject("Project 2");
        const project = await pool.projectIdToIndex("Project 1");
        const project2 = await pool.projectIdToIndex("Project 2");
        await pool.connect(owner).deleteProject("Project 1");
        await pool.connect(owner).addProject("Project 3");
        await pool.connect(owner).addProject("Project 4");
        await pool.connect(owner).addProject("Project 5");

        const project3 = await pool.projectIdToIndex("Project 3");
        const project4 = await pool.projectIdToIndex("Project 4");
        const project5 = await pool.projectIdToIndex("Project 5");
        console.log(project2, project3, project4, project5)
        // expect(project.projectId).to.equal("Project 1");
    });

    it("should transfer tokens to the pool", async function () {
        const projectId = "Project_1";
        await pool.connect(owner).addToken(token);
        await pool.connect(owner).addProject(projectId);
        const project = await pool.projectIdToIndex(projectId);
        const mintBalance = ethers.toBigInt(10000);
        const initialBalance = ethers.toBigInt(100);
        await token.mint(user.address, mintBalance);
        await token.connect(user).approve(pool, initialBalance);

        const amount = ethers.toBigInt(20);

        const result = await pool.connect(user).transferToPool('Project_1', amount.toString(), token);
        const tx = await result.wait();
        expect(await token.balanceOf(pool)).to.equal(amount);
        // const recipient = await pool.recipients(projectId, token);
    });
});