// SPDX-License-Identifier: MIT
// Specify the Solidity version.
pragma solidity >=0.8.0 <0.9.0;

// Import the required interfaces. These are commented out for now, but you'll need to uncomment them once available.
import "./IERC20.sol";
import "./HowContract.sol";

// The main contract: Laws.
contract Laws {
    // Store the address of the contract's owner and the timestamp when the contract was created.
    address public owner;
    uint256 public immutable creationTimestamp;
    // a token for this set of laws IN's thing...
    IERC20 public empToken;
    // VARIABLE FOR FLOW CONTROL IN ABSCENCE OF PASSING TIME
    bool passTime;

    // The address of the 'how' contract
    address public howContract;

    // The structure of a Law, containing the content of the law and the addresses of the 'who' and 'how' contracts.
    struct Law {
        address targetContract;
        address associatedContract;
        HowContract how;
        string content;
    }

    // Store all laws in a mapping, indexed by a unique identifier, and keep a count of the total number of laws.
    mapping(uint256 => Law) public laws;
    uint256 public lawCount;

    event Log(string message);
    // Emit these events when laws are added, edited, or deleted.
    event LawAdded(uint256 indexed lawId, string content);
    event LawEdited(uint256 indexed lawId, string newContent);
    event LawDeleted(uint256 indexed lawId);

    // The constructor is called when the contract is first created. It sets the owner and the creation timestamp.
    constructor(address _owner) {
        owner = _owner;
        creationTimestamp = block.timestamp;
        lawCount = 0;
        passTime = true;     /// FLOW CONTROL
        howContract = address(this);
    }

    // This function sets the 'how' contract. It can only be called by the owner, and only within the first 90 days.
    function setHowContract(address _howContract) external {
        require(block.timestamp < creationTimestamp + 90 days, "Can only set 'how' contract within the first 90 days");
        require(msg.sender == owner, "Only the owner can set the 'how' contract");
        howContract = _howContract;
    }

    // This modifier checks if the function is called by the owner within the first 90 days or
    // by an authorized address after the first 90 days.
    modifier onlyOwnerOrAuthorized(uint256 _lawId) {   // correct modifier when other contracts are present
        if ((block.timestamp < creationTimestamp + 90 days) && passTime) {    // FLOW CONTROL
            emit Log("Interaction PRIOR!");
            passTime = false;    /// FLOW CONTROL
            require(msg.sender == owner, "Only the owner can perform this action within the first 90 days");
        } else {
            emit Log("Interaction POSTERIOR!");
            HowContract how = HowContract(howContract);
            require(how.isChangeAccepted(_lawId), "The proposed change was not accepted");
        }
        _;
    }

    // This function adds a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function addLaw(string memory _content, address _targetContract, address _associatedContract, uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
    {
        laws[_lawId] = Law({
            targetContract: _targetContract,
            associatedContract: _associatedContract,
            how: HowContract(howContract),
            content: _content
        });
        lawCount += 1;
        emit LawAdded(_lawId, _content);
    }

    // This function edits a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function editLaw(string memory _newContent, uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
    {
        laws[_lawId].content = _newContent;
        emit LawEdited(_lawId, _newContent);
    }

    // This function deletes a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function deleteLaw(uint256 _lawId) 
        external 
        onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
    {
        delete laws[_lawId];
        lawCount -= 1;
        emit LawDeleted(_lawId);
    }
}
