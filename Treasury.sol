pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./TokenTransferProposal.sol";
import "./Laws.sol";

contract Treasury {
    address public owner; // The contract owner's wallet address
    IERC20 public token; // The token contract instance (EMP)
    Laws public laws; // The laws contract instance

    // The law ID that governs the treasury contract editing permissions
    uint256 public treasuryPermissionLawId;

    mapping(address => bool) public validProposals; // Mapping to store valid proposals

    event TokensSent(address indexed to, uint256 amount); // Event to indicate when tokens are sent

    // Modifier to ensure that only valid proposals can perform certain actions
    modifier onlyValidProposal() {
        require(validProposals[msg.sender], "Invalid or unapproved proposal");
        _;
    }

    // Modifier to enforce permissions from the Laws contract for the treasury
    modifier enforceTreasuryPermission() {
        require(laws.laws(treasuryPermissionLawId).permissions[msg.sender], "Permission denied");
        _;
    }

    // Constructor to initialize the contract with the owner, token, laws, and treasuryPermissionLawId
    constructor(address _owner, address _token, address _laws, uint256 _treasuryPermissionLawId) {
        owner = _owner;
        token = IERC20(_token);
        laws = Laws(_laws);
        treasuryPermissionLawId = _treasuryPermissionLawId;
    }

    // Function to send tokens from the treasury to a specified address
    function sendTokens(address _to, uint256 _amount) external onlyValidProposal {
        token.transfer(_to, _amount);
        emit TokensSent(_to, _amount);
    }

    // Function to add a valid proposal, ensuring the sender has the necessary permissions
    function addValidProposal(address _proposal) external enforceTreasuryPermission {
        validProposals[_proposal] = true;
    }

    // Function to remove a valid proposal, ensuring the sender has the necessary permissions
    function removeValidProposal(address _proposal) external enforceTreasuryPermission {
        validProposals[_proposal] = false;
    }
}
