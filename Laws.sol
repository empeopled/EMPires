pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./TokenTransferProposal.sol";
import "./Treasury.sol";

contract Laws {
    address public owner;
    uint256 public immutable creationTimestamp;
    
    struct Law {
        string content;
        mapping(address => bool) permissions;
    }

    mapping(uint256 => Law) public laws;
    uint256 public lawCount;

    Treasury public treasury;

    // Mapping to store the legitimacy of contract addresses
    mapping(address => bool) public legitimateContracts;

    event LawAdded(uint256 indexed lawId, string content);
    event LawEdited(uint256 indexed lawId, string newContent);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyTreasury() {
        require(msg.sender == address(treasury), "Only the treasury can perform this action");
        _;
    }

    modifier enforcePermission(uint256 _lawId) {
        require(msg.sender == owner || laws[_lawId].permissions[msg.sender], "Permission denied");
        _;
    }

    constructor(address _owner, address _treasury) {
        owner = _owner;
        treasury = Treasury(_treasury);
        creationTimestamp = block.timestamp;
    }

    // Other functions...

    // Function to add a legitimate contract address
    function addLegitimateContract(address _contractAddress, uint256 _lawId) external enforcePermission(_lawId) {
        legitimateContracts[_contractAddress] = true;
    }

    // Function to remove a legitimate contract address
    function removeLegitimateContract(address _contractAddress, uint256 _lawId) external enforcePermission(_lawId) {
        legitimateContracts[_contractAddress] = false;
    }

    // Function to check the legitimacy of a contract address
    function isLegitimateContract(address _contractAddress) external view returns (bool) {
        return legitimateContracts[_contractAddress];
    }
}
