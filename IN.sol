// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;       // Specify the Solidity version.

import "./IERC20.sol";
import "./INhow_Interface.sol";
import "./INhow_default.sol";

contract Laws {
    address public founderAddr;     // Literally for historical reasons!
    uint256 public immutable creationTimestamp;

    // The address of the 'how' contract (logic for decision making)
    address public governContractAddr;

    // VARIABLE FOR FLOW CONTROL IN ABSCENCE OF PASSING TIME. DEBUGGING ONLY!
    bool passTime1;
    bool passTime2;

    // The structure of a Law, containing the content of the law and the addresses of the 'who' and 'how' contracts.
    struct Law {
        address associatedContract;    // Any on-chain logic related to this law will point to its contrac(s)
        address author;                // (Optional) Wallet address of person who proposes the law
        string content;
        uint16 status;                 // specifies: proposed, approved
    }

    // Store all laws in a mapping, indexed by a unique identifier, and keep a count of the total number of laws.
    mapping(address => Law) public laws;
    uint256 public lawCount;

    event Log(string message);

    // The constructor is called when the contract is first created. It sets the owner and the creation timestamp.
    constructor(address _founderAddress) {
        founderAddr = _founderAddress;
        creationTimestamp = block.timestamp;
        lawCount = 0;
        passTime1 = true;     /// FLOW CONTROL; DEBUGGING ONLY!
        passTime2 = true;     /// FLOW CONTROL; DEBUGGING ONLY!
        governContractAddr = address(0);      // the initial address needs to be universally invalid
        GovernContract_Default firstHow = new GovernContract_Default(founderAddr);
        governContractAddr = address(firstHow);
    }

    // This function sets the 'decision making' contract.
    function setGovernContract(address _newGovernContractAddr) external
    changeGovernAuthorized(_newGovernContractAddr)  {
        governContractAddr = _newGovernContractAddr;
    }

    // This modifier checks for conditions...
    modifier changeGovernAuthorized(address _newGovernContractAddr) {
        if ((block.timestamp < creationTimestamp + 90 days) && passTime1) {    // FLOW CONTROL; DEBUGGING ONLY!
            emit Log("Interaction PRIOR!");
            passTime1 = false;    /// FLOW CONTROL; MIMICS PASSING OF the 90 DAYS DEBUGGING ONLY!
            require(msg.sender == founderAddr, "Only the founder can perform this action within the first 90 days");
        } else {
            emit Log("Interaction POSTERIOR!");
            GovernContract how = GovernContract(governContractAddr);    // creates local instance from reference to existing
            if( passTime2 ) {
                emit Log("Passing time for the second and last time! PRIOR 2");
                passTime2 = false;    /// FLOW CONTROL; MIMICS PASSING OF the 90 DAYS DEBUGGING ONLY!
            } else {
                emit Log("Interaction POSTERIOR 2");
                require(how.changeDecisionProcess(_newGovernContractAddr, msg.sender),"HowContract returned FALSE" );
            }
        }
        _;
    }

    // This function addes a law structure to the contract
    function proposeLaw(string memory _content, address _associatedContract)  external
    checkProposedLaw(_associatedContract)
    {
        laws[_associatedContract] = Law({
            associatedContract: _associatedContract,
            author: msg.sender,
            content: _content,
            status: 1     // set to non-zero such that a check can be made for existance in the mapping
        });
        lawCount += 1;
    }

    // This modifier checks for conditions:
    // 1. law struct has to not already be includes
    // 2. the governance contract does not reject this type of law (for reasons unknown)
    modifier checkProposedLaw(address _associatedContract) {
        emit Log("Modifier checking for proposed law conditions.");
        require(laws[_associatedContract].status == 0,"This law contract is already in the map!");
        GovernContract how = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(how.notifyOfProposedLaw(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects law proposal." );
        _;
    }

    // This function certifies a previously added law structure to be accepted as a law
    function addLaw(address _associatedContract)  external
    checkAddingLaw(_associatedContract)
    {
        laws[_associatedContract].status = 2;
    }

    // This modifier checks for conditions:
    // 1. the law this struct represents has to have been proposed first
    // 2. the governance contract has to approve the _specific_ law
    modifier checkAddingLaw(address _associatedContract) {
        emit Log("Modifier checking for proposed law conditions.");
        require(laws[_associatedContract].status == 1,"This law contract is not a proposed law!");
        GovernContract how = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(how.notifyOfApprovingLaw(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects law addition." );
        _;
    }

}
