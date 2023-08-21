// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Arrays.sol";

contract ERC20Mock is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Arrays for uint256[];

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => uint256[]) private snapshotIds;
    mapping (address => uint256[]) private snapshotBalances;

    uint256 private currSnapshotId;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    event Snapshot(uint256 id);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(_msgSender(), initialSupply * 10**uint256(decimals_));
        _mint(address(this), initialSupply * 10**uint256(decimals_));
    }

    function snapshot() public returns (uint256) {
        currSnapshotId += 1;
        emit Snapshot(currSnapshotId);
        return currSnapshotId;
    }

    function balanceOfAt(address _account, uint256 _snapshotId) public view returns (uint256) {
        require(_snapshotId > 0 && _snapshotId <= currSnapshotId);

        uint256 idx = snapshotIds[_account].findUpperBound(_snapshotId);

        if (idx == snapshotIds[_account].length) {
            return balanceOf(_account);
        } else {
            return snapshotBalances[_account][idx];
        }
    }

    function _updateSnapshot(address _account) internal {
        if (_lastSnapshotId(_account) < currSnapshotId) {
            snapshotIds[_account].push(currSnapshotId);
            snapshotBalances[_account].push(balanceOf(_account));
        }
    }

    function _lastSnapshotId(address _account) internal returns (uint256) {
        uint256[] storage snapshots = snapshotIds[_account];

        if (snapshots.length == 0) {
            return 0;
        } else {
            return snapshots[snapshots.length - 1];
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _updateSnapshot(msg.sender);
        _updateSnapshot(recipient);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _updateSnapshot(sender);
        _updateSnapshot(recipient);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}