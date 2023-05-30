// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Import the required interfaces. The "how" contract is commented out for now but you'll need to uncomment it once available.
//import "./IERC20.sol";
//import "./TokenTransferProposal.sol";
//import "./HowContract.sol";

contract Laws {
    address public owner;
    uint256 public immutable creationTimestamp;

    struct Law {
        address targetContract;
        //HowContract how;  // Reference to a smart contract that encapsulates the decision/governance logic
        address associatedContract; // Additional reference to another contract this law relates to
        string content;
    }

    mapping(uint256 => Law) public laws;
    uint256 public lawCount;

    event LawAdded(uint256 indexed lawId, string content);
    event LawEdited(uint256 indexed lawId, string newContent);
    event LawDeleted(uint256 indexed lawId);

    constructor(address _owner) {
        owner = _owner;
        creationTimestamp = block.timestamp;
        lawCount = 0;
    }

    modifier onlyOwnerOrAuthorized(uint256 _lawId) {
        if (block.timestamp < creationTimestamp + 90 days) {
            require(msg.sender == owner, "Only the owner can perform this action within the first 90 days");
        } else {
            // Uncomment this line once the how contract is available
            //require(laws[_lawId].how.isChangeAccepted(msg.sender, _lawId), "The proposed change was not accepted");
        }
        _;
    }

    function addLaw(string memory _content, address _targetContract, address _associatedContract, uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)
    {
        laws[_lawId] = Law({
            targetContract: _targetContract,
            //how: HowContract(_howContract), // Assign the 'how' smart contract when it's ready
            associatedContract: _associatedContract,
            content: _content
        });
        lawCount += 1;
        emit LawAdded(_lawId, _content);
    }

    function editLaw(string memory _newContent, uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)
    {
        laws[_lawId].content = _newContent;
        emit LawEdited(_lawId, _newContent);
    }

    function deleteLaw(uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)
    {
        delete laws[_lawId];
        lawCount -= 1;
        emit LawDeleted(_lawId);
    }
}
