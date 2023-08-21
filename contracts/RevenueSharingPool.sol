// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract RevenueSharingPool is Proxy, Ownable, ReentrancyGuard {
    using SafeERC20 for ERC20;

    address public implAddress;
    mapping(address => bool) public whitelist;
    ERC20[] public tokenList;

    struct Recipient {
        uint256 projectIdIndex;
        uint256 lastTimestamp;
    }
    uint256 public projectMaxIndex;
    mapping(uint256 => mapping(address => Recipient)) public recipients;
    mapping(string => uint256) public projectIdToIndex;

    event ProjectAdded(string projectId);
    event TokenAdded(address indexed tokenAddress);
    event TokensReceived(address sender, address tokenAddress, uint256 amount, string projectId, uint256 fromBlock, uint256 toBlock);

    modifier onlyValidProject(string memory projectId) {
        require(projectIdToIndex[projectId] != 0, "Invalid project ID");
        _;
    }

    function _implementation()  internal view override returns (address){
        return  implAddress;
    }

    function setImplAddress(address _implAddress) external onlyOwner{
        implAddress = _implAddress;
    }

    function isTokenAdded(ERC20 tokenAddress) public view returns (bool) {
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (address(tokenList[i]) == address(tokenAddress)) {
                return true;
            }
        }
        return false;
    }

    function addToken(ERC20 tokenAddress) external onlyOwner {
        require(address(tokenAddress) != address(0), "Invalid token address");
        require(!isTokenAdded(tokenAddress), "Token already added");
        tokenList.push(tokenAddress);
        emit TokenAdded(address(tokenAddress));
    }

    function addProject(string memory projectId) external onlyOwner {
        require(projectIdToIndex[projectId] == 0, "Project with this ID already exists");
        uint256 projectIdIndex = projectMaxIndex + 1;
        projectIdToIndex[projectId] = projectIdIndex;
        emit ProjectAdded(projectId);
        projectMaxIndex = projectIdIndex;
    }

    function deleteProject(string memory projectId) external onlyOwner onlyValidProject(projectId) {
        uint256 projectIndexToDelete = projectIdToIndex[projectId];
        require(projectIndexToDelete != 0, "Project not found");
        for (uint256 i = 0; i < tokenList.length; i++) {
            ERC20 token = tokenList[i];
            Recipient storage recipient = recipients[projectIndexToDelete][address(token)];


            require(recipient.lastTimestamp == 0, "Tokens have been transferred to this project");
        }
        projectIdToIndex[projectId] = 0;
    }

    function transferToPool(string memory projectId, uint256 amount, ERC20 tokenAddress) public onlyValidProject(projectId) nonReentrant {
        require(address(tokenAddress) != address(0), "Invalid token address");
        require(isTokenAdded(tokenAddress), "Token is not added");
        uint256 senderBalance = tokenAddress.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance");

        uint256 projectIdIndex = getIndexProject(projectId);
        Recipient storage recipient = recipients[projectIdIndex][address(tokenAddress)];

        uint256 lastUpdate = recipient.lastTimestamp;
        recipient.projectIdIndex  = projectIdIndex;
        recipient.lastTimestamp = block.number;
        tokenAddress.safeTransferFrom(msg.sender, address(this), amount);
        emit TokensReceived(msg.sender, address(tokenAddress), amount, projectId, lastUpdate + 1, block.number);
    }

    function getIndexProject(string memory projectId) public returns (uint256) {
        uint256 projectIdIndex = projectIdToIndex[projectId];
        return projectIdIndex;
    }

}
