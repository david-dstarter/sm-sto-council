// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "./U2UToken.sol";


contract RevenueSharingPool is Proxy, Ownable, ReentrancyGuard {
    using SafeERC20 for ERC20;

    address public implAddress;
    mapping(address => bool) public whitelist;

    mapping(string => uint256) public lastBlockPerProject;

    event RevenueReceived(address sender, address tokenAddress, uint256 amount, string projectId, uint256 fromBlock, uint256 toBlock);
    event TokenAdded(address tokenAddress);
    event TokenRemoved(address tokenAddress);

    function _implementation()  internal view override returns (address){
        return  implAddress;
    }

    function setImplAddress(address _implAddress) external onlyOwner{
        implAddress = _implAddress;
    }

    function setWhitelist(U2UToken token) external onlyOwner {
        whitelist[address(token)] = true;
        emit TokenAdded(address(token));
    }

    function removeFromWhiteList(U2UToken token) external onlyOwner {
        whitelist[address(token)] = false;
        emit TokenRemoved(address(token));
    }


    function transferToPool(string memory projectId, uint256 amount, U2UToken token) public  nonReentrant {
        require(address(token) != address(0), "Invalid token address");
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance");
        token.transferFrom(msg.sender, address(this), amount);
        uint256 lastBlock = lastBlockPerProject[projectId] + 1;
        uint256 currentBlock = block.number;
        emit RevenueReceived(_msgSender(), address(token), amount, projectId, lastBlock, currentBlock);
        lastBlockPerProject[projectId] = currentBlock;
    }
}