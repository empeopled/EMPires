// The version of Solidity we are using.
pragma solidity >=0.8.0 <0.9.0;

// The interfaces for other smart contracts we need.
//import "./IERC20.sol";
//import "./TokenTransferProposal.sol";
//import "./WhoContract.sol";  // Smart contract listing token holders
//import "./HowContract.sol";  // Smart contract outlining decision/governance logic

// This is the main contract: Laws.
contract Laws {
    // State variables storing the address of the owner and the contract creation timestamp.
    address public owner;
    uint256 public immutable creationTimestamp;

    // The structure of a Law, containing the referenced smart contract, 
    // the addresses of the 'who' and 'how' contracts, and the content.
    struct Law {
        address targetContract;
        //WhoContract who;
        //HowContract how;
        string content;
    }

    // A mapping from law ID to Law struct, and a count of all laws.
    mapping(uint256 => Law) public laws;
    uint256 public lawCount;

    // Events that get emitted when laws are added, edited, or deleted.
    event LawAdded(uint256 indexed lawId, string content);
    event LawEdited(uint256 indexed lawId, string newContent);
    event LawDeleted(uint256 indexed lawId);

    // Constructor: Called when the contract is first created. Sets the owner and creation timestamp.
    constructor(address _owner) {
        owner = _owner;
        creationTimestamp = block.timestamp;
    }

    // Modifier: Ensures a function can only be called by the owner and only within the first 90 days.
    modifier onlyOwnerInFirst90Days() {
        require(msg.sender == owner && block.timestamp < creationTimestamp + 90 days,
                "Only the owner can perform this action within the first 90 days");
        _;
    }

    // Modifier: Ensures a function can only be called by authorized addresses after the first 90 days.
    modifier onlyAuthorizedAfter90Days(uint256 _lawId) {
        require(
            //block.timestamp >= creationTimestamp + 90 days &&
            //laws[_lawId].who.isTokenHolder(msg.sender) &&
            //laws[_lawId].how.isChangeAccepted(msg.sender, _lawId),
            block.timestamp >= creationTimestamp + 90 days,
            "Only authorized token holders as per 'how' contract can perform this action after 90 days"
        );
        _;
    }

    // Function to add a law. It can only be called by the owner in the first 90 days or authorized addresses after that.
    function addLaw(string memory _content, address _targetContract,
                    //address _whoContract, address _howContract,
                     uint256 _lawId) 
        external 
        onlyOwnerInFirst90Days
        onlyAuthorizedAfter90Days(_lawId)
    {
        laws[_lawId] = Law({
            targetContract: _targetContract,
            //who: WhoContract(_whoContract),
            //how: HowContract(_howContract),
            content: _content
        });
        emit LawAdded(_lawId, _content);
    }

    // Function to edit a law. It can only be called by the owner in the first 90 days or authorized addresses after that.
    function editLaw(string memory _newContent, uint256 _lawId) 
        external 
        onlyOwnerInFirst90Days
        onlyAuthorizedAfter90Days(_lawId)
    {
        laws[_lawId].content = _newContent;
        emit LawEdited(_lawId, _newContent);
    }

    // Function to delete a law. It can only be called by the owner in the first 90 days or authorized addresses after that.
    function deleteLaw(uint256 _lawId) 
        external 
        onlyOwnerInFirst90Days
        onlyAuthorizedAfter90Days(_lawId)
    {
        // Do something to "pop" the law from the map; this is missing // laws[_lawId] .....
        emit LawDeleted(_lawId );
    }
}