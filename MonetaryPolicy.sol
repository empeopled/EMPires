pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Laws.sol";
import "./Treasury.sol";

contract MonetaryPolicy {
    IERC20 public token; // The ERC20 token contract instance
    Laws public laws; // The Laws contract instance
    Treasury public treasury; // The Treasury contract instance

    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // Total supply of 1 billion tokens (assuming 18 decimals)
    uint256 public constant DISTRIBUTION_PERIOD = 10 * 365 days; // Distribution period of 10 years
    uint256 public constant MONTHLY_ALLOCATION = TOTAL_SUPPLY / (10 * 12); // Evenly distributed monthly allocation

    uint256 public startTimestamp; // The start timestamp of the distribution
    uint256 public endTimestamp; // The end timestamp of the distribution
    uint256 public lastDistributionTimestamp; // The timestamp of the last distribution

    // Modifier to ensure that only the authorized addresses can perform certain actions
    modifier enforcePermission(uint256 _lawId) {
        require(laws.isLegitimateContract(msg.sender), "Permission denied");
        require(laws.laws(_lawId).permissions[msg.sender], "Permission denied");
        _;
    }

    constructor(
        address _token,
        address _laws,
        address _treasury,
        uint256 _startTimestamp
    ) {
        token = IERC20(_token);
        laws = Laws(_laws);
        treasury = Treasury(_treasury);
        startTimestamp = _startTimestamp;
        endTimestamp = startTimestamp + DISTRIBUTION_PERIOD;
    }

    // Function to distribute the monthly allocation to the treasury
    function distributeMonthlyAllocation(uint256 _lawId) external enforcePermission(_lawId) {
        require(block.timestamp >= startTimestamp, "Distribution has not started yet");
        require(block.timestamp <= endTimestamp, "Distribution has already ended");

        uint256 timeSinceLastDistribution = block.timestamp - lastDistributionTimestamp;
        require(timeSinceLastDistribution >= 30 days, "Monthly allocation has already been distributed");

        lastDistributionTimestamp = block.timestamp;
        token.transfer(address(treasury), MONTHLY_ALLOCATION);
    }

    // Function to update the start timestamp of the distribution
    function updateStartTimestamp(uint256 _newStartTimestamp, uint256 _lawId) external enforcePermission(_lawId) {
        require(block.timestamp < startTimestamp, "Distribution has already started");
        startTimestamp = _newStartTimestamp;
        endTimestamp = startTimestamp + DISTRIBUTION_PERIOD;
    }
}
