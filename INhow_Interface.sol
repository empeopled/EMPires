// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";  // Import the ERC20 interface.

interface GovernContract { 
    // a function that can contain "emit LOG("");" to help with EVM testing
    function simplePing() external;

    // a function to respond back with "true" or "false" to change the decision process (to change this contract)
    function changeDecisionProcess(address newDecisonContractAddr, address motionerAddr) external returns (bool);

    // a function to notify this governance contract that a law has been proposed
    // (It is meant to return "true" if everything went well; things can go wrong, like proposing a law twice.)
    function notifyOfProposedLaw(address associatedLawContract, address motionerAddr) external returns (bool);

    // a function to notify this governance contract to dictate if a proposed law has been approved
    // (It is meant to return "true" if this _specific_ law is approved and "false" if not. The key factor
    // here is the specificity of the contract to be approved; the governance contract can keep track of what
    // this means, and also who is performing this interaction/transaction.)
    function notifyOfApprovingLaw(address associatedLawContract, address motionerAddr) external returns (bool);

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

}