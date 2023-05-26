// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//This is a simplified example and does not include all the necessary checks and balances you would want in a production contract. 
//For example, it doesn't implement secure vote tallying, and it doesn't handle what happens if 
//the token balance of a voter changes during the voting period.


import "./IERC20.sol";  // Import the ERC20 interface.

contract HowContract {
    // Reference to the EMP token contract.
    IERC20 public empToken;
    
    // Duration of the voting period (7 days).
    uint256 public constant VOTING_PERIOD = 7 days;

    // The structure of a vote, containing the start time, yes count, no count, and a mapping of who has voted.
    struct Vote {
        uint256 startTime;
        uint256 yesCount;
        uint256 noCount;
        mapping(address => bool) hasVoted;
    }

    // A mapping from proposal IDs to votes.
    mapping(uint256 => Vote) public votes;

    // Constructor: Sets the EMP token contract address.
    constructor(address _empToken) {
        empToken = IERC20(_empToken);
    }

    // Opens the voting for a proposal.
    function openVoting(uint256 _proposalId) external {
        // Check that the sender has more than 0 EMP tokens.
        require(empToken.balanceOf(msg.sender) > 0, "Only EMP token holders can open a vote");
        
        // Start the voting process.
        votes[_proposalId] = Vote({
            startTime: block.timestamp,
            yesCount: 0,
            noCount: 0
        });
    }

    // Casts a vote.
    function castVote(uint256 _proposalId, bool _vote) external {
        // Get a reference to the vote.
        Vote storage vote = votes[_proposalId];
        
        // Check that the voting period is still ongoing.
        require(block.timestamp < vote.startTime + VOTING_PERIOD, "Voting period has ended");

        // Check that the sender hasn't already voted.
        require(!vote.hasVoted[msg.sender], "You have already voted on this proposal");

        // Get the voter's EMP token balance.
        uint256 voteWeight = empToken.balanceOf(msg.sender);

        // Update the vote counts.
        if (_vote) {
            vote.yesCount += voteWeight;
        } else {
            vote.noCount += voteWeight;
        }

        // Record that the sender has now voted.
        vote.hasVoted[msg.sender] = true;
    }

    // Checks if a change is accepted.
    function isChangeAccepted(uint256 _proposalId) external view returns (bool) {
        // Get a reference to the vote.
        Vote storage vote = votes[_proposalId];
        
        // Check that the voting period has ended.
        require(block.timestamp >= vote.startTime + VOTING_PERIOD, "Voting period is still ongoing");

        // Return true if the yes votes outnumber the no votes, false otherwise.
        return vote.yesCount > vote.noCount;
    }
}
