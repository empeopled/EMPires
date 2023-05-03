pragma solidity ^0.8.0;

import "./IERC20.sol"; // Import the ERC20 interface

contract VotingModule {
    IERC20 public EMP; // The EMP token contract address

    // A struct to represent a vote
    struct Vote {
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) hasVoted;
    }

    // Mapping to store votes for each proposal
    mapping(bytes32 => Vote) public votes;

    // Events
    event VoteCasted(bytes32 indexed proposalHash, address indexed voter, bool vote, uint256 weight);

    constructor(address _empToken) {
        EMP = IERC20(_empToken);
    }

    // A modifier to ensure only authorized contracts can create votes
    modifier onlyAuthorized(address _caller) {
        // Implement logic to check if the _caller is authorized
        _;
    }

    // Function to initialize a new vote for a proposal
    // This function should be called by the authorized contract
    function initializeVote(bytes32 _proposalHash) external onlyAuthorized(msg.sender) {
        // Initialize an empty vote for the proposal
        // No need to explicitly initialize, as the default values for uint256 are 0
    }

    // Function for EMP token holders to cast their vote
    function castVote(bytes32 _proposalHash, bool _vote) external {
        Vote storage vote = votes[_proposalHash]; // Get the vote associated with the proposal
        require(!vote.hasVoted[msg.sender], "You have already voted on this proposal");

        uint256 weight = EMP.balanceOf(msg.sender); // Get the voter's token balance
        require(weight > 0, "You must hold EMP tokens to vote");

        if (_vote) {
            vote.yesVotes += weight;
        } else {
            vote.noVotes += weight;
        }

        vote.hasVoted[msg.sender] = true;
        emit VoteCasted(_proposalHash, msg.sender, _vote, weight);
    }

    // Function to get the result of a vote
    function getVoteResult(bytes32 _proposalHash) external view returns (uint256, uint256) {
        Vote storage vote = votes[_proposalHash];
        return (vote.yesVotes, vote.noVotes);
    }
}
//In this version, the initializeVote function is added to allow an authorized contract to create a new vote for a proposal. 
//The authorized contract should pass a unique identifier (a hash of the proposal, for example) to represent the proposal. 
//The castVote and getVoteResult functions now use this identifier instead of a proposal ID to work with votes. 
//A modifier onlyAuthorized is also introduced to restrict access to the initializeVote function.
//In the contract that manages proposals, you would interact with the VotingModule contract by calling the initializeVote function when a new proposal is created. 
//When needed, you can also call the castVote and getVoteResult functions to handle voting and results for proposals.
//Note that the onlyAuthorized modifier is left empty, as the authorization logic depends on your specific requirements. 
//You can implement a simple whitelist, use an access control library like OpenZeppelin's AccessControl, or develop your own custom logic to determine if a contract is authorized to create votes.