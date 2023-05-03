pragma solidity ^0.8.0;

import "./IERC20.sol"; // Import the ERC20 interface
import "./VotingModule.sol"; // Import the VotingModule contract
import "./TreasurerElection.sol"; // Import the TreasurerElection contract
import "./Treasury.sol"; // Import the Treasury contract

contract TokenTransferProposal {
    IERC20 public EMP; // The EMP token contract address
    VotingModule public votingModule; // The voting module contract instance
    TreasurerElection public treasurerElection; // The treasurer election contract instance
    Treasury public treasury; // The treasury contract instance

    bytes32 public proposalHash; // Unique identifier for the token transfer proposal
    bool public proposalExecuted; // Boolean to indicate if the proposal has been executed

    address public recipient; // The recipient address for the token transfer
    uint256 public amount; // The amount of tokens to transfer

    // Event to indicate when the proposal has been executed
    event ProposalExecuted(address indexed recipient, uint256 amount);

    constructor(
        address _empToken,
        address _votingModule,
        address _treasurerElection,
        address _treasury,
        address _recipient,
        uint256 _amount
    ) {
        EMP = IERC20(_empToken);
        votingModule = VotingModule(_votingModule);
        treasurerElection = TreasurerElection(_treasurerElection);
        treasury = Treasury(_treasury);

        recipient = _recipient;
        amount = _amount;

        proposalHash = keccak256(abi.encodePacked(block.timestamp, _recipient, _amount));
        votingModule.initializeVote(proposalHash);
    }

    // Function for treasurers to cast their vote on the token transfer proposal
    function castVote(bool _vote) external {
        require(!proposalExecuted, "Proposal has been executed");

        // Check if the msg.sender is an elected treasurer
        require(treasurerElection.isTreasurer(msg.sender), "Only treasurers can vote");

        votingModule.castVote(proposalHash, _vote);
    }

    // Function to register an approved proposal with the treasury
    function registerProposal() external {
        require(!proposalExecuted, "Proposal has been executed");

        (uint256 yesVotes, uint256 noVotes) = votingModule.getVoteResult(proposalHash);

        // Check if the majority of treasurers voted in favor of the proposal
        require(yesVotes > noVotes, "Proposal not approved by treasurers");

        // Register the proposal with the treasury
        treasury.registerProposal(address(this));

        proposalExecuted = true;
        emit ProposalExecuted(recipient, amount);
    }
}


///In this example, the TokenTransferProposal contract requires the EMP token contract, 
//the voting module, the treasurer election contract, the treasury address, the recipient address, 
//and the amount of tokens to transfer. It initializes a new vote for the proposal using the voting module 
//and allows elected treasurers to cast their vote.
//After the voting process, the executeProposal function can be called to execute the token transfer if the majority of treasurers voted in favor of the proposal. 
//The proposalExecuted flag is set to true to indicate the proposal has been executed.