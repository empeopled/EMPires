// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address delegate, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// An example ERC-20 smart contract that keeps balanes of tokens
// (A mint and burn mechanism, not needed by the ERC-20 standard, was added to make
// this example work.)
contract EmpeopledToken is IERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    constructor()  {
        name = "Empeopled0";
        symbol = "EMPX";
        decimals = 0;
        _totalSupply = 0;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        // use temporary variables
        balances[msg.sender] = balances[msg.sender].subSafe(numTokens);
        balances[receiver] = balances[receiver].addSafe(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint256) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address recipient, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].subSafe(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].subSafe(numTokens);
        balances[recipient] = balances[recipient].addSafe(numTokens);
        emit Transfer(owner, recipient, numTokens);
        return true;
    }

    // burning tokens is _not_ an ERC-20 mandated method; this is here as reminder
    // that the supply of tokens needs to come from somewhere
    function burn(uint256 numTokens) external payable virtual {
        balances[msg.sender] = balances[msg.sender].subSafe(numTokens);
        _totalSupply -= numTokens;
        emit Transfer(msg.sender, address(0), numTokens);
    }

    // minting tokens is _not_ an ERC-20 mandated method; this is here as reminder
    // that the supply of tokens needs to come from somewhere
    function mint(address account, uint256 numTokens) external virtual {
        require(account != address(0), "Attempt to mint to the zero address");
        balances[account] = balances[account].addSafe(numTokens);
        _totalSupply += numTokens;
        emit Transfer(address(0), account, numTokens);
    }
}

library SafeMath {
    function subSafe( uint256 a, uint256 b ) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function addSafe( uint256 a, uint256 b ) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}