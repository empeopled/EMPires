// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";  // Import the ERC20 interface.

interface DecisionContract { 
    // a function that can contain "emit LOG("");" to help with EVM testing
    function simplePing() external;

    // a function that can contain "emit LOG("");" to help with EVM testing
    function changeDecisionProcess(address newDecisonContractAddr) external returns (bool);


    // a function that is meant to return "true" used for debugging
    // This function is useful for testing when using a "require()" inside another smart contract.
    // For example, suppose contract "ProcessContract" uses this "HowContract" to determine the
    // conditions of the execution of one of its methods, say, "makeInternalChanges()". The method
    // can be decorated with a "modifier" that checks for execution conditions, like this:
    // function makeInternalChanges() {
    //    require(how.isChangePossible(),"Cannot make changes!");
    //    // code that makes changes goes here
    // }
    // The function's implementation will always return true, and allow execution. But we can hardwire
    // a "false" to be returned for testing failure of the condition.
    function returnTrue() external returns (bool) ;

//----- random ideas
    // Functions that can exist in an concrete implementation of the contract that  resemble a democracy
    //function openVoting(uint256 _proposalId) external;
    //function castBallot(uint256 _proposalId, bool ballot) external;
}