// SPDX-License-Identifier: MIT
// Specify the Solidity version.
pragma solidity >=0.8.0 <0.9.0;

// Import the required interfaces. These are commented out for now, but you'll need to uncomment them once available.
//import "./IERC20.sol";
//import "./TokenTransferProposal.sol";
//import "./WhoContract.sol";
//import "./HowContract.sol";

// The main contract: Laws.
contract Laws {
    // Store the address of the contract's owner and the timestamp when the contract was created.
    address public owner;
    uint256 public immutable creationTimestamp;

    // The structure of a Law, containing the content of the law and the addresses of the 'who' and 'how' contracts.
    struct Law {
        address targetContract;
        //WhoContract who;
        //HowContract how;
        string content;
    }

    // Store all laws in a mapping, indexed by a unique identifier, and keep a count of the total number of laws.
    mapping(uint256 => Law) public laws;
    uint256 public lawCount;

    // Emit these events when laws are added, edited, or deleted.
    event LawAdded(uint256 indexed lawId, string content);
    event LawEdited(uint256 indexed lawId, string newContent);
    event LawDeleted(uint256 indexed lawId);

    // The constructor is called when the contract is first created. It sets the owner and the creation timestamp.
    constructor(address _owner) {
        owner = _owner;
        creationTimestamp = block.timestamp;
        lawCount = 0;
    }

    // This modifier checks if the function is called by the owner within the first 90 days or
    // by an authorized address after the first 90 days.
/// modifier onlyOwnerOrAuthorized(uint256 _lawId) {   // correct modifier when other contracts are present
    modifier onlyOwnerOrAuthorized() {                   // lean modifier within present context
        if (block.timestamp < creationTimestamp + 90 days) {
            require(msg.sender == owner, "Only the owner can perform this action within the first 90 days");
        } else {
            // Uncomment these lines once the who and how contracts are available.
            //require(laws[_lawId].who.isTokenHolder(msg.sender), "Only token holders can perform this action after 90 days");
            //require(laws[_lawId].how.isChangeAccepted(msg.sender, _lawId), "The proposed change was not accepted");
        }
        _;
    }

    // This function adds a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function addLaw(string memory _content, address _targetContract, uint256 _lawId) 
        external 
    /// onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
        onlyOwnerOrAuthorized()         // lean modifier within present context
    {
        laws[_lawId] = Law({
            targetContract: _targetContract,
            //who: WhoContract(_whoContract),
            //how: HowContract(_howContract),
            content: _content
        });
        lawCount += 1;
        emit LawAdded(_lawId, _content);
    }

    // This function edits a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function editLaw(string memory _newContent, uint256 _lawId) 
        external 
    /// onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
        onlyOwnerOrAuthorized()         // lean modifier within present context
    {
        laws[_lawId].content = _newContent;
        emit LawEdited(_lawId, _newContent);
    }

    // This function deletes a law. It can be called by the owner within the first 90 days, and by authorized addresses afterwards.
    function deleteLaw(uint256 _lawId) 
        external 
    /// onlyOwnerOrAuthorized(_lawId)   // correct modifier when other contracts are present
        onlyOwnerOrAuthorized()         // lean modifier within present context
    {
        delete laws[_lawId];
        lawCount -= 1;
        emit LawDeleted(_lawId);
    }
}
