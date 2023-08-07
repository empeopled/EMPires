// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./INhow_Interface.sol";
import "./IERC20.sol";  // Import the ERC20 interface.

contract GovernContract_ByVote is GovernContract { 
    uint256 public constant VOTING_PERIOD = 7 days;  // The duration of the voting period.
    // the "public" modified automatically generates a getter funtion

    event Log(string message);
    event LogAddress(string message, address _addr);

    // The structure of a vote, containing the start time, yes count, no count, and a mapping of who has voted.
    struct Vote {
        uint256 startTime;
        uint256 yesCount;
        uint256 noCount;
        mapping(address => bool) hasVoted;
    }

    // A mapping from proposed law contract to a vote structure.
    mapping(address => Vote) public votes;

    constructor() {
        emit Log("BYVOTE How constructor!");
    }


    function changeDecisionProcess(address newDecisonContractAddr) external returns (bool) {
        return false;
    }

    // a function that is asked to accept a law as having been proposed
    function notifyOfProposedLaw(address associatedLawContract) external returns (bool) {
        emit LogAddress("The contract was notified of a proposed law", associatedLawContract);
        // Always "reject" for now
        return false;
    }

    // a function that is asked to specify if a law is to be approved
    // (The incoming law contract address can be used to check for the _specific_ law to be approved.)
    function notifyOfApprovingLaw(address associatedLawContract) external returns (bool) {
        emit LogAddress("The contract was notified to approve a law", associatedLawContract);
        return false;
    }

// ---- Functions that will be used for voting
    // The openVoting function starts the voting process for a proposal.
    function openVoting(address proposedLawContract) external {     
        // Start the voting process and initialize the counts to zero.
        votes[proposedLawContract].startTime = block.timestamp;
        votes[proposedLawContract].yesCount = 0;
        votes[proposedLawContract].noCount = 0;
    }

    // The castBallot function allows an address to vote on a proposal.
    function castBallot(address _proposedLawContract, bool ballot) external {
        // Store the vote struct in memory to avoid excessive reads from storage.
        Vote storage vote = votes[_proposedLawContract];
        
        // Ensure the voting period is still ongoing.
        require(block.timestamp < vote.startTime + VOTING_PERIOD, "Voting period has ended");

        // Check that the voter hasn't already voted.
        require(!vote.hasVoted[msg.sender], "You have already voted on this proposal");

        // Update the vote counts based on the voter's decision and their token balance.
        if (ballot) {
            vote.yesCount += 1;
        } else {
            vote.noCount += 1;
        }

        // Record that this address has voted.
        vote.hasVoted[msg.sender] = true;
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