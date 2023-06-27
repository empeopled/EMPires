// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./INhow_Interface.sol";
import "./IERC20.sol";  // Import the ERC20 interface.

contract DecisionContract_Default is DecisionContract { 
    address dictatorAddr;
    address allowedContractAddr;

    event Log(string message);

    constructor(address _dictatorAddr) {
        emit Log("DEFAULT How constructor!");
        dictatorAddr = _dictatorAddr;
        allowedContractAddr = address(0);     // this is a purposely invalid address
    }

    // This modifier checks for whether the sender of the transaction/interaction is the dictator
    modifier onlyAuthorized() {
        emit Log("Modifier of OnlyAuthorized is being checked");
        require(msg.sender == dictatorAddr,
                "Only the dictator can perofrm this action!");
        _;
    }


    // This modifier checks for whether the dictator has allowed for this change to take place
    // It checks whether the address of the decision-making contract is what the dictator has authorized
    modifier contractAuthorized(address newDecisionContractAddr) {
        emit Log("Modifier of ContractAuthorized is being checked");
        require(newDecisionContractAddr == allowedContractAddr,
                 "Only a specific contract can be used as replacement!");
        _;
    }

    // authorizes the change in the decision-making process
    // The function will return "true" if the condition of the dictator having authorized the specific
    // decision-making process contract to replace the existing one in the caller is met
    function changeDecisionProcess(address newDecisonContractAddr) external
     contractAuthorized(newDecisonContractAddr) returns (bool) {
         // we reset the address of candidate contracts in case we are given back control as dictator...
         // ...so that nobody can inject their own governance during that potential transition!
         allowedContractAddr = address(0);
        return true;
    }

    // a function that stores the internal address of the decision-making contract to which we will transition
    // The function can only be executed by the dictator
    // (This function is needed because if there were a simple method of giving up power, anyone can subsequently
    // specify an arbitrary, non-approved by the dictator, decision-making contract. Therefore, the dictator needs
    // to approve a specific contract to which they surrender their power.
    function initiateChange(address newDecisonContractAddr) external
     onlyAuthorized() {
        emit Log("The dictator is initiating change to a new contract!");
        allowedContractAddr = newDecisonContractAddr;
    }

//--- these functions are for DEBUGGING
    // a function to interact with the contract to make sure it is there...
    function simplePing() external {
        emit Log("Pong from HowContract_Default!");
    }

    // a function that always returns "true" to be used for "require()" calls debugging
    function returnTrue() external returns (bool) {
        emit Log("Returning TRUE from HowContract_Default!");
        return true;
        //return false;    // uncomment this to demonstrate "require()" failing!
    }

}