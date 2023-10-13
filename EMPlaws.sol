// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;       // Specify the Solidity version.

import "./IERC20.sol";
import "./EMPgov_interface.sol";
import "./EMPgov_default.sol";

contract Laws {
    address public founderAddr;     // Literally for historical reasons!
    uint256 public immutable creationTimestamp;

    // The address of the governance ontract (logic for decision making)
    address public governContractAddr;

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
        GovernContract_Default firstGov = new GovernContract_Default(founderAddr);
        governContractAddr = address(firstGov);
    }

    // This function sets the 'decision making' contract.
    function setGovernContract(address _newGovernContractAddr) external
    changeGovernAuthorized(_newGovernContractAddr)  {
        governContractAddr = _newGovernContractAddr;
    }

    // This modifier checks for conditions...
    modifier changeGovernAuthorized(address _newGovernContractAddr) {
        GovernContract gov = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(gov.changeDecisionProcess(_newGovernContractAddr, msg.sender),"HowContract returned FALSE" );
        _;
    }

    // This function adds a law structure to the contract's storage map
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
    // 1. law struct has to not already be included
    // 2. the governance contract does not reject this type of law (for reasons unknown)
    modifier checkProposedLaw(address _associatedContract) {
        emit Log("Modifier checking for proposed law conditions.");
        require(laws[_associatedContract].status == 0,"This law contract is already in the map!");
        GovernContract gov = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(gov.notifyOfProposedLaw(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects law proposal." );
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
        emit Log("Modifier checking for law adding conditions.");
        require(laws[_associatedContract].status == 1,"This law contract is not a proposed law!");
        GovernContract gov = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(gov.notifyOfApprovingLaw(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects law addition." );
        _;
    }

    // This function is meant to propose that a law is removed
    function proposeLawRemoval(address _associatedContract)  external
    checkProposedLawRemoval(_associatedContract)
    {
        // nothing ot be done
    }

    // This modifier checks for conditions:
    // 1. the law this struct represents has to have been instated first
    // 2. the governance contract has to approve removal of the _specific_ law
    modifier checkProposedLawRemoval(address _associatedContract) {
        emit Log("Modifier checking for proposed law-removal conditions.");
        require(laws[_associatedContract].status == 2,"This law contract is not an existing law!");
        GovernContract gov = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(gov.notifyOfProposedLawRemoval(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects removal prposal." );
        _;
    }

    // This function certifies the removal of a previously added law; law is flagged as inactive
    function removeLaw(address _associatedContract)  external
    checkRemovingLaw(_associatedContract)
    {
        laws[_associatedContract].status = 3;
        lawCount -= 1;
    }

    // This modifier checks for conditions:
    // 1. the law this struct represents has to have been instated first
    // 2. the governance contract has to approve removing the _specific_ law
    modifier checkRemovingLaw(address _associatedContract) {
        emit Log("Modifier checking for law removing conditions.");
        require(laws[_associatedContract].status == 2,"This law contract is not an existing law!");
        GovernContract gov = GovernContract(governContractAddr);    // creates local instance from reference to existing
        require(gov.notifyOfApprovingLawRemoval(_associatedContract, msg.sender),"HowContract returned FALSE. Rejects law addition." );
        _;
    }

}
