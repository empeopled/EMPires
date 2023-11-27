// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// a "membership token" smart contract
contract EmpeopledUnitToken {
    string public name;
    string public symbol;
    uint256 public _totalUnits;
    mapping(address => bool) members;

    // event to emit when a member obtains or discards the membership token
    event LogAddress(string message, address addr);

    constructor()  {
        name = "EmpeopledUnit";
        symbol = "EMPU";
        _totalUnits = 0;
    }

    // method to indicate how many tokens are in existance
    function totalSupply() public view returns (uint256) {
        return _totalUnits;
    }

    // method to query the smart contract for whether an address has a token
    // (This is mean to be queried by other smart contracts. An example is of a contract
    // that is part of a voting process.)
    function checkMembership(address tokenOwner) public view returns (bool) {
        return members[tokenOwner];
    }

    // Modifiers of methods
    modifier isMember(address _sender) {
        require(checkMembership(_sender), "Sender is not a member");
        _;
    }

    modifier notMember(address _addr) {
        require(!checkMembership(_addr), "Recipient is already a member");
        _;
    }

    // method to transfer the token from one member to a non-member
    function transfer(address receiver) external isMember(msg.sender) notMember(receiver) returns (bool) {
        members[msg.sender] = false;
        members[receiver] = true;
        emit LogAddress("Departing member (in an exchange): ",msg.sender);
        emit LogAddress("New member (in an exchange): ",receiver);
        return members[receiver];
    }

    function burn() external virtual isMember(msg.sender) {
        members[msg.sender] = false;
        _totalUnits -= 1;
        emit LogAddress("Departing member: ",msg.sender);
    }

    function mint() external virtual notMember(msg.sender) {
        members[msg.sender] = true;
        _totalUnits += 1;
        emit LogAddress("New member: ",msg.sender);
    }
}
