// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract U2UToken is  ERC20Snapshot,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        snapshot();
    }

    event TotalBalanceAt(uint256 snapshotId, uint256 totalSupply);

    function snapshot() public returns (bool) {
        _snapshot();
        uint256 currenSnapshot = _getCurrentSnapshotId();
        uint256 totalSupply =  totalSupplyAt(currenSnapshot);
        emit TotalBalanceAt(currenSnapshot, totalSupply);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function mint(address account, uint256 amount) internal  returns (bool)  {
        _mint(account, amount);
        return true;
    }

    function burn(address account, uint256 amount) internal  returns (bool) {
        _burn(account, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _beforeTokenTransfer(from, to, amount);
        _transfer(from, to, amount);
        return true;
    }
}
