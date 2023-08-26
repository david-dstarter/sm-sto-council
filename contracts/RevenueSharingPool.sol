// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "./U2UToken.sol";


contract RevenueSharingPool is Proxy, Ownable, ReentrancyGuard {
    using SafeERC20 for U2UToken;

    address public implAddress;
    mapping(address => bool) private acceptTokenList;
    mapping(uint256 => uint256) private lastBlockPerProject;
    mapping(uint256 => uint256) private revenuePeriod;
    address[] public tokenList;

    struct SnapShotBalance {
        uint256 snapshotId;
        uint256 totalBalance;
    }
    mapping (uint256 => mapping(address => SnapShotBalance)) private balanceWithProject;

    event RevenueReceived(address sender, address tokenAddress, uint256 amount, string projectId, string id, uint256 fromTime, uint256 toTime);
    event TokenBalanceSnapshot(address token, uint256 snapshotId, uint256 totalSupply, string id);

    event TokenAdded(address tokenAddress);
    event TokenRemoved(address tokenAddress);

    function _implementation()  internal view override returns (address){
        return  implAddress;
    }

    function setImplAddress(address _implAddress) external onlyOwner{
        implAddress = _implAddress;
    }

    function setTokenlist(U2UToken token) external onlyOwner {
        acceptTokenList[address(token)] = true;
        tokenList.push(address(token));
        emit TokenAdded(address(token));
    }

    function getRevenueSharingPerId(string memory id) public view returns (uint256) {
        return revenuePeriod[uint256(keccak256(abi.encode(keccak256(bytes(id)))))];
    }

    function revenueClaimable(string memory id, address sender) external view returns (uint256) {
        uint256 revenueId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        uint256 revenue = revenuePeriod[revenueId];
        uint256 userTotalBalance = 0;
        uint256 totalBalance = 0;
        uint256 claimable = 0;
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (acceptTokenList[tokenList[i]] == true) {
                U2UToken token = U2UToken(tokenList[i]);
                uint256 snapshotId = balanceWithProject[revenueId][tokenList[i]].snapshotId;
                uint256 balanceAt = token.balanceOfAt(sender, snapshotId);
                userTotalBalance += balanceAt;
                totalBalance += balanceWithProject[revenueId][tokenList[i]].totalBalance;
            }
        }
        if (totalBalance > 0) {
            claimable = userTotalBalance * revenue / totalBalance;
        }else {
            claimable = 0;
        }
        return claimable;
    }

    function removeFromTokenList(U2UToken token) external onlyOwner {
        acceptTokenList[address(token)] = false;
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (tokenList[i] == address(token)) {
                tokenList[i] = tokenList[tokenList.length - 1];
                tokenList.pop();
                break;
            }
        }
        emit TokenRemoved(address(token));
    }

    function _snapshotTokens(string memory id) private returns (bool) {
        uint256 revenueId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (acceptTokenList[tokenList[i]] == true) {
                // snapshot balance
                U2UToken token = U2UToken(tokenList[i]);
                uint256 snapshotId = token.snapshot();
                uint256 balanceAt = token.totalSupplyAt(snapshotId);
                balanceWithProject[revenueId][tokenList[i]] = SnapShotBalance({
                    snapshotId : snapshotId,
                    totalBalance : balanceAt
                });
                emit TokenBalanceSnapshot(tokenList[i], snapshotId, balanceAt, id);
            }
        }
        return true;
    }

    function transferTokenToPool(string memory id, string memory projectId, U2UToken token, uint256 amount) external nonReentrant {
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance");
        uint256 revenueId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        uint256 pId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        _snapshotTokens(id);
        token.transferFrom(msg.sender, address(this), amount);
        uint256 lastTime;
        uint256 currentTime = block.timestamp;
        if (lastBlockPerProject[pId] == 0) {
            lastTime = block.timestamp;
        }else {
            lastTime = lastBlockPerProject[pId] + 1;
        }
        emit RevenueReceived(_msgSender(), address(token), amount, projectId, id, lastTime, currentTime);
        lastBlockPerProject[pId] = currentTime;
        revenuePeriod[revenueId] = amount;
    }



    function transferToPool(string memory id, string memory projectId) external payable nonReentrant {
        require(address(0) != address(this), "Contract address must not be zero address");
        uint256 revenueId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        uint256 pId = uint256(keccak256(abi.encode(keccak256(bytes(id)))));
        _snapshotTokens(id);
        uint256 lastTime;
        uint256 amount = msg.value;
        if (lastBlockPerProject[pId] == 0) {
            lastTime = block.timestamp;
        }else {
            lastTime = lastBlockPerProject[pId] + 1;
        }
        uint256 currentTime = block.timestamp;
        emit RevenueReceived(_msgSender(), address(0), amount, projectId, id, lastTime, currentTime);
        lastBlockPerProject[pId] = currentTime;
        revenuePeriod[revenueId] = amount;
    }
}