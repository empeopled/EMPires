// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";  // Import the ERC20 interface.

interface GovernContract { 
    // a function to respond back with "true" or "false" to change the decision process (it is meant to inform
    // a contract that is inquiring on whether to change from this contract to some other governance mechanism)
    function changeDecisionProcess(address newDecisonContractAddr, address motionerAddr) external returns (bool);

    // a function to notify this governance contract that a law has been proposed
    // (It is meant to return "true" if everything went well; things can go wrong, like proposing a law twice.)
    function notifyOfProposedLaw(address associatedLawContract, address motionerAddr) external returns (bool);

    // a function to notify this governance contract to dictate if a proposed law has been approved
    // (It is meant to return "true" if this _specific_ law is approved and "false" if not. The key factor
    // here is the specificity of the contract to be approved; the governance contract can keep track of what
    // this means, and also who is performing this interaction/transaction.)
    function notifyOfApprovingLaw(address associatedLawContract, address motionerAddr) external returns (bool);

    // a function to notify this governance contract of a proposal to remove an existing law
    // (It is meant to return "true" if everything went well; things can go wrong, like a law not existing
    function notifyOfProposedLawRemoval(address associatedLawContract, address motionerAddr) external returns (bool);

    // a function to notify this governance contract to dictate if the removal of an existing law is approved
    // (It is meant to return "true" if this _specific_ law is approved for removal and "false" if not. The key factor
    // here is the specificity of the contract to be removed; the governance contract can keep track of what
    // this means, and also who is performing this interaction/transaction.)
    function notifyOfApprovingLawRemoval(address associatedLawContract, address motionerAddr) external returns (bool);
}