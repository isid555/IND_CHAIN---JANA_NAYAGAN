// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MultiPoolLoanSystem.sol"; // Import the individual pool contract

contract MultiPoolLoanSystemFactory is Ownable {

    // --- State Variables ---

    uint256 public nextPoolId; // Counter for unique pool IDs
    uint256[] public allPools; // List of all created pool IDs

    // Mappings to track deployed pool instances and their creators
    mapping(uint256 => address) public poolIdToAddress;       // Maps pool ID to its contract address
    mapping(address => uint256[]) public userCreatedPools;    // Tracks pools created by a specific user

    // --- Events ---

    event PoolCreated(uint256 indexed poolId, address indexed creator, address indexed poolAddress, uint256 contributionAmount, uint256 maxParticipants);

    // --- Constructor ---

    constructor(address initialOwner) Ownable(initialOwner) {
        nextPoolId = 1; // Start pool IDs from 1
    }

    // --- External Functions ---

    /**
     * @dev Creates a new MultiPoolLoanSystem contract (a lending pool).
     * @param _contributionAmount The fixed amount (in Wei) each participant contributes per round. Must be > 0.
     * @param _collateralAmount The amount (in Wei) of collateral required from each participant to join the pool. Must be > 0.
     * @param _totalRounds The total number of lending rounds in this pool. Must be between 1 and 50.
     * @param _intervalDuration The duration (in seconds) of each lending round. Must be > 0.
     * This includes the bidding period.
     * @param _biddingDuration The duration (in seconds) within each round for participants to place bids.
     * Must be > 0 and less than _intervalDuration.
     * @param _maxParticipants The maximum number of participants allowed in this pool. Must be between 1 and 100.
     * @return poolId The unique ID assigned to the newly created pool.
     * @return poolAddress The address of the newly deployed MultiPoolLoanSystem contract.
     */
    function createPool(
        uint256 _contributionAmount,
        uint256 _collateralAmount,
        uint256 _totalRounds,
        uint256 _intervalDuration,
        uint256 _biddingDuration,
        uint256 _maxParticipants
    ) external returns (uint256 poolId, address poolAddress) {
        // Input validation hints are already present in the MultiPoolLoanSystem constructor.
        // Adding more explicit checks here can provide earlier feedback to the user.
        require(_contributionAmount > 0, "Contribution amount must be greater than 0.");
        require(_collateralAmount > 0, "Collateral amount must be greater than 0.");
        require(_totalRounds > 0 && _totalRounds <= 50, "Total rounds must be between 1 and 50.");
        require(_maxParticipants > 0 && _maxParticipants <= 100, "Max participants must be between 1 and 100.");
        require(_intervalDuration > 0, "Interval duration must be greater than 0.");
        require(_biddingDuration > 0 && _biddingDuration < _intervalDuration, "Bidding duration must be greater than 0 and less than interval duration.");


        poolId = nextPoolId++; // Assign new unique ID

        // Deploy a new MultiPoolLoanSystem contract instance
        MultiPoolLoanSystem newPool = new MultiPoolLoanSystem(
            poolId,
            _contributionAmount,
            _collateralAmount,
            _totalRounds,
            _intervalDuration,
            _biddingDuration,
            _maxParticipants,
            msg.sender // The user who called createPool on the factory is the pool's creator/owner
        );

        poolAddress = address(newPool); // Get the address of the newly deployed contract

        // Register the new pool
        poolIdToAddress[poolId] = poolAddress;
        allPools.push(poolId);
        userCreatedPools[msg.sender].push(poolId);

        emit PoolCreated(poolId, msg.sender, poolAddress, _contributionAmount, _maxParticipants);

        return (poolId, poolAddress);
    }

    // --- View Functions ---

    /**
     * @dev Returns the contract address for a given pool ID.
     * @param _poolId The unique ID of the pool.
     * @return The address of the MultiPoolLoanSystem contract.
     */
    function getPoolAddress(uint256 _poolId) external view returns (address) {
        require(poolIdToAddress[_poolId] != address(0), "Pool does not exist.");
        return poolIdToAddress[_poolId];
    }

    /**
     * @dev Returns a list of all pool IDs created by this factory.
     * @return An array of all created pool IDs.
     */
    function getAllPools() external view returns (uint256[] memory) {
        return allPools;
    }

    /**
     * @dev Returns a list of pool IDs created by a specific user.
     * @param _user The address of the user.
     * @return An array of pool IDs created by the specified user.
     */
    function getUserCreatedPools(address _user) external view returns (uint256[] memory) {
        return userCreatedPools[_user];
    }

    /**
     * @dev Returns the total number of pools created so far.
     * @return The total count of pools created.
     */
    function getTotalPoolsCreated() external view returns (uint256) {
        return allPools.length;
    }
}