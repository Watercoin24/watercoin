
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WaterCoin {
    string public name = "WaterCoin";
    string public symbol = "WTR";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    uint256 public constant INITIAL_SUPPLY = 10_000_000_000 * 10**18;
    uint256 public constant BURN_AMOUNT_FIRST_3_YEARS = 5_000_000 * 10**18;
    uint256 public constant BURN_AMOUNT_AFTER = 1_000_000 * 10**18;

    uint256 public startTimestamp;
    uint256 public lastBurnTimestamp;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = INITIAL_SUPPLY;
        balanceOf[owner] = INITIAL_SUPPLY;
        emit Transfer(address(0), owner, INITIAL_SUPPLY);
        startTimestamp = block.timestamp;
        lastBurnTimestamp = block.timestamp;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Not enough balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Not enough balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function dailyBurn() public onlyOwner {
        require(block.timestamp >= lastBurnTimestamp + 1 days, "Already burned today");

        uint256 daysSinceStart = (block.timestamp - startTimestamp) / 1 days;
        uint256 burnAmount;

        if (daysSinceStart < 365 * 3) {
            burnAmount = BURN_AMOUNT_FIRST_3_YEARS;
        } else {
            burnAmount = BURN_AMOUNT_AFTER;
        }

        require(balanceOf[owner] >= burnAmount, "Not enough tokens to burn");
        balanceOf[owner] -= burnAmount;
        totalSupply -= burnAmount;
        emit Transfer(owner, address(0), burnAmount);
        lastBurnTimestamp = block.timestamp;
    }
}
