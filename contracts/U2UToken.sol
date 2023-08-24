// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract U2UToken is ERC20, ERC20Snapshot,Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {}

    function snapshot() public returns (uint256) {
        return _snapshot();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) virtual {
        super._beforeTokenTransfer(from, to, amount);
    }

    function getCurrentSnapshotId() public view returns (uint256) {
        uint256 currentSnapshotId = _getCurrentSnapshotId();
        return currentSnapshotId;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function mint(address account, uint256 amount) external onlyOwner{
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _beforeTokenTransfer(from, to, amount);
        _transfer(from, to, amount);
        return true;
    }
}
