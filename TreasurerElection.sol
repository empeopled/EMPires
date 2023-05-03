pragma solidity ^0.8.0;

import "./VotingModule.sol";
import "./Laws.sol";

contract TreasurerElection {
    VotingModule public votingModule; // The VotingModule contract instance
    Laws public laws; // The Laws contract instance

    // The law ID that governs the TreasurerElection contract editing permissions
    uint256 public treasurerElectionPermissionLawId;

    uint256 public constant TREASURER_COUNT = 12; // The number of treasurers to be elected
    address[] public treasurers; // Array to store the elected treasurers' addresses

    // Modifier to enforce permissions from the Laws contract for the TreasurerElection
    modifier enforceTreasurerElectionPermission() {
        require(laws.laws(treasurerElectionPermissionLawId).permissions[msg.sender], "Permission denied");
        _;
    }

    // Constructor to initialize the contract with the VotingModule, Laws, and treasurerElectionPermissionLawId
    constructor(address _votingModule, address _laws, uint256 _treasurerElectionPermissionLawId) {
        votingModule = VotingModule(_votingModule);
        laws = Laws(_laws);
        treasurerElectionPermissionLawId = _treasurerElectionPermissionLawId;
    }

    // Function to start the treasurer election process, ensuring the sender has the necessary permissions
    function startElection() external enforceTreasurerElectionPermission {
        require(treasurers.length == 0, "Election already started");

        // Fetch the top 12 candidates from the VotingModule contract
        address[] memory candidates = votingModule.getTopCandidates(TREASURER_COUNT);

        // Add the candidates to the treasurers array
        for (uint256 i = 0; i < candidates.length; i++) {
            treasurers.push(candidates[i]);
        }
    }

    // Function to reset the election, ensuring the sender has the necessary permissions
    function resetElection() external enforceTreasurerElectionPermission {
        // Clear the treasurers array
        while (treasurers.length > 0) {
            treasurers.pop();
        }
    }
}
