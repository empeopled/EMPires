// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";  // Import the ERC20 interface.

contract HowContract {
    IERC20 public empToken;  // The token used for weighted voting.
    
    uint256 public constant VOTING_PERIOD = 7 days;  // The duration of the voting period.

    // The structure of a vote, containing the start time, yes count, no count, and a mapping of who has voted.
    struct Vote {
        uint256 startTime;
        uint256 yesCount;
        uint256 noCount;
        mapping(address => bool) hasVoted;
    }

    // A mapping from proposal IDs to votes.
    mapping(uint256 => Vote) public votes;

    // The constructor sets the address for the EMP token.
    constructor(address _empToken) {
        empToken = IERC20(_empToken);
    }

    // The openVoting function starts the voting process for a proposal.
    function openVoting(uint256 _proposalId) external {
        // Only holders of the EMP token can open a vote.
        require(empToken.balanceOf(msg.sender) > 0, "Only EMP token holders can open a vote");
        
        // Start the voting process and initialize the counts to zero.
        votes[_proposalId] = Vote({
            startTime: block.timestamp,
            yesCount: 0,
            noCount: 0
        });
    }

    // The castVote function allows an address to vote on a proposal.
    function castVote(uint256 _proposalId, bool _vote) external {
        // Store the vote struct in memory to avoid excessive reads from storage.
        Vote storage vote = votes[_proposalId];
        
        // Ensure the voting period is still ongoing.
        require(block.timestamp < vote.startTime + VOTING_PERIOD, "Voting period has ended");

        // Check that the voter hasn't already voted.
        require(!vote.hasVoted[msg.sender], "You have already voted on this proposal");

        // Get the number of tokens held by the voter.
        uint256 voteWeight = empToken.balanceOf(msg.sender);

        // Update the vote counts based on the voter's decision and their token balance.
        if (_vote) {
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
