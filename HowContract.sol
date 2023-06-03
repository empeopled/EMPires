// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";  // Import the ERC20 interface.

contract HowContract {
    IERC20 public token;  // The token used for weighted voting.
    
    uint256 public constant VOTING_PERIOD = 7 days;  // The duration of the voting period.

    event Log(string message);

    // The structure of a vote, containing the start time, yes count, no count, and a mapping of who has voted.
    struct Vote {
        uint256 startTime;
        uint256 yesCount;
        uint256 noCount;
        mapping(address => bool) hasVoted;
    }

    // A mapping from proposal IDs to votes.
    mapping(uint256 => Vote) public votes;

    // The constructor sets the address for the token.
    //constructor(IERC20 token_) {
    //    token = token_;
    constructor(address tokenAddr) {
        emit Log("How constructor!");
        token = IERC20(tokenAddr);
    }

    // The openVoting function starts the voting process for a proposal.
    function openVoting(uint256 _proposalId) external {
        // Only holders of the EMP token can open a vote.
        //require(token.balanceOf(msg.sender) > 0, "Only token holders can open a vote");
        
        // Start the voting process and initialize the counts to zero.
        votes[_proposalId].startTime = block.timestamp;
        votes[_proposalId].yesCount = 0;
        votes[_proposalId].noCount = 0;
    }

    // The castBallot function allows an address to vote on a proposal.
    function castBallot(uint256 _proposalId, bool ballot) external {
        // Store the vote struct in memory to avoid excessive reads from storage.
        Vote storage vote = votes[_proposalId];
        
        // Ensure the voting period is still ongoing.
        require(block.timestamp < vote.startTime + VOTING_PERIOD, "Voting period has ended");

        // Check that the voter hasn't already voted.
        require(!vote.hasVoted[msg.sender], "You have already voted on this proposal");

        // Get the number of tokens held by the voter.
        uint256 voteWeight = token.balanceOf(msg.sender);

        // Update the vote counts based on the voter's decision and their token balance.
        if (ballot) {
            vote.yesCount += voteWeight;
        } else {
            vote.noCount += voteWeight;
        }

        // Record that this address has voted.
        vote.hasVoted[msg.sender] = true;
    }

    // The isChangeAccepted function checks if a change was accepted after the voting period has ended.
    function isChangeAccepted(uint256 _proposalId) external view returns (bool) {
        // Store the vote struct in memory to avoid excessive reads from storage.
        Vote storage vote = votes[_proposalId];
        
        // Ensure the voting period has ended.
        require(block.timestamp >= vote.startTime + VOTING_PERIOD, "Voting period is still ongoing");

        // A change is accepted if the total weighted 'yes' votes are greater than the 'no' votes.
        return vote.yesCount > vote.noCount;
    }
}