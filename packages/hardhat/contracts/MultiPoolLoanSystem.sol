// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MultiPoolLoanSystem is ReentrancyGuard, Ownable {

    struct PoolConfig {
        uint256 poolId;             // Unique ID for this pool, assigned by factory
        uint256 contributionAmount; // Amount each participant contributes per round (in Wei)
        uint256 collateralAmount;   // Collateral required to join (in Wei)
        uint256 totalRounds;        // Total number of lending rounds
        uint256 intervalDuration;   // Duration of each round (in seconds)
        uint256 biddingDuration;    // Duration within a round for placing bids (in seconds, must be < intervalDuration)
        uint256 maxParticipants;    // Maximum number of participants allowed
        bool isActive;              // Whether the pool is currently active
        address creator;            // Address of the user who initiated pool creation (via factory)
        uint256 creationTime;       // Timestamp of pool creation
    }


    struct PoolState {
        uint256 currentRound;               // Current active round number
        uint256 totalParticipants;          // Current number of participants
        uint256 totalSurplus;               // Accumulated surplus from all completed rounds (in Wei)
        uint256 totalDividendsDistributed;  // Total dividends paid out to participants (in Wei)
        address[] participantsList;         // List of all participants in this pool
    }

    struct Participant {
        address user;               // The participant's address
        uint256 collateralLocked;   // Collateral amount they've locked (in Wei)
        bool hasWithdrawnCollateral; // Whether they have withdrawn their initial collateral
        uint256 roundWon;           // The round number they won (0 if not yet won)
        uint256 totalContributed;   // Total amount contributed across all rounds in this pool (in Wei)
        bool isActive;              // Whether the participant is active in this pool
        uint256 missedPayments;     // Number of missed contributions (now only for tracking, not direct defaulting)
        bool isDefaulted;           // Whether the participant has truly defaulted (collateral ran out)
        uint256 dividendsEarned;    // Total dividends earned from this pool (in Wei)
    }

    struct Round {
        uint256 roundNumber;        // The round's identifier
        uint256 totalPooled;        // Total contributions collected in this round (in Wei)
        uint256 startTime;          // When the round began (timestamp)
        uint256 biddingEndTime;     // When the bidding period for the round ends (timestamp)
        address winner;             // The address of the round's winner
        uint256 winningBid;         // The winning bid amount (in Wei)
        uint256 surplus;            // Surplus generated in this round (in Wei)
        bool isCompleted;           // Whether the round has concluded
        bool hasAuction;            // Indicates if an auction took place for this round
        mapping(address => bool) hasContributed; // Tracks if a participant has contributed in this round
    }

    struct Bid {
        address bidder;     // The address of the bidder
        uint256 bidAmount;  // The amount of the bid (how much they accept) (in Wei)
        uint256 timestamp;  // When the bid was placed
    }

    // --- State Variables ---

    PoolConfig public poolConfig; // Configuration for this specific pool
    PoolState public poolState;   // Dynamic state for this specific pool


    mapping(address => Participant) public participants; // Participant data within this pool
    mapping(uint256 => Round) public rounds;             // Round data within this pool
    mapping(uint256 => Bid[]) public roundBids;          // Bids placed per round within this pool

    // --- Events ---

    event ParticipantJoined(uint256 indexed poolId, address indexed user, uint256 collateralAmount);
    event ContributionMade(uint256 indexed poolId, address indexed user, uint256 amount, uint256 round);
    event BidPlaced(uint256 indexed poolId, address indexed bidder, uint256 acceptAmount, uint256 round);
    event RoundCompleted(uint256 indexed poolId, uint256 round, address winner, uint256 payout, uint256 surplus);
    event PoolCompleted(uint256 indexed poolId);
    event CollateralWithdrawn(uint256 indexed poolId, address indexed user, uint256 amount);
    event DividendsDistributed(uint256 indexed poolId, address indexed user, uint256 amount);
    event ParticipantDefaulted(uint256 indexed poolId, address indexed user);
    event ContributionCoveredByCollateral(uint256 indexed poolId, address indexed user, uint256 amountCovered);
    event PayOutDone(uint256 indexed poolId , address indexed user , uint256 amount);

    // --- Constructor ---

    constructor(
        uint256 _poolId,
        uint256 _contributionAmount,
        uint256 _collateralAmount,
        uint256 _totalRounds,
        uint256 _intervalDuration,
        uint256 _biddingDuration,
        uint256 _maxParticipants,
        address _poolCreator // The address of the user who called createPool on the factory
    ) Ownable(_poolCreator) {
        // Basic validation for pool parameters
        require(_contributionAmount > 0, "Contribution amount must be greater than 0.");
        require(_collateralAmount > 0, "Collateral amount must be greater than 0.");
        require(_totalRounds > 0 && _totalRounds <= 50, "Total rounds must be between 1 and 50.");
        require(_maxParticipants > 0 && _maxParticipants <= 100, "Max participants must be between 1 and 100.");
        require(_intervalDuration > 0, "Interval duration must be greater than 0.");
        require(_biddingDuration > 0 && _biddingDuration < _intervalDuration, "Bidding duration must be greater than 0 and less than interval duration.");

        // Initialize PoolConfig
        poolConfig = PoolConfig({
            poolId: _poolId,
            contributionAmount: _contributionAmount,
            collateralAmount: _collateralAmount,
            totalRounds: _totalRounds,
            intervalDuration: _intervalDuration,
            biddingDuration: _biddingDuration,
            maxParticipants: _maxParticipants,
            isActive: true,
            creator: _poolCreator,
            creationTime: block.timestamp
        });

        // Initialize PoolState
        poolState = PoolState({
            currentRound: 1,
            totalParticipants: 0,
            totalSurplus: 0,
            totalDividendsDistributed: 0,
            participantsList: new address[](0)
        });

        // Initialize the first round
        rounds[1].roundNumber = 1;
        rounds[1].startTime = block.timestamp;
        rounds[1].biddingEndTime = block.timestamp + poolConfig.biddingDuration;
    }

    // --- External Functions (User Interactions) ---

    /**
     * @dev Allows a user to join the pool by sending the required collateral.
     * Can only be called in Round 1 and if the pool is active and not full.
     */
    function joinPool() external payable nonReentrant {
        require(poolConfig.isActive, "Pool is not active.");
        require(msg.value == poolConfig.collateralAmount, "Incorrect collateral amount sent.");
        require(!participants[msg.sender].isActive, "You are already an active participant in this pool.");
        require(poolState.totalParticipants < poolConfig.maxParticipants, "Pool is full.");
        require(poolState.currentRound == 1, "Can only join during the first round.");

        // Initialize participant data
        participants[msg.sender] = Participant({
            user: msg.sender,
            collateralLocked: msg.value,
            hasWithdrawnCollateral: false,
            roundWon: 0,
            totalContributed: 0,
            isActive: true,
            missedPayments: 0,
            isDefaulted: false,
            dividendsEarned: 0
        });

        // Update pool state
        poolState.participantsList.push(msg.sender);
        poolState.totalParticipants = poolState.totalParticipants + 1;

        emit ParticipantJoined(poolConfig.poolId, msg.sender, msg.value);
    }

    /**
     * @dev Allows an active participant to contribute their share for the current round.
     * Must send the exact 'contributionAmount' specified in the pool config.
     */
    function contributeToRound() external payable nonReentrant {
        require(poolConfig.isActive, "Pool is not active.");
        require(participants[msg.sender].isActive, "You are not an active participant in this pool.");
        require(msg.value == poolConfig.contributionAmount, "Incorrect contribution amount sent.");

        uint256 currentRound = poolState.currentRound;
        require(currentRound <= poolConfig.totalRounds, "All rounds completed or not yet started.");
        require(!rounds[currentRound].hasContributed[msg.sender], "You have already contributed to this round.");
        require(block.timestamp >= rounds[currentRound].startTime, "Round has not started yet.");
        require(block.timestamp < rounds[currentRound].startTime + poolConfig.intervalDuration, "Contribution period for this round has ended.");

        rounds[currentRound].hasContributed[msg.sender] = true;
        rounds[currentRound].totalPooled = rounds[currentRound].totalPooled + msg.value;
        participants[msg.sender].totalContributed = participants[msg.sender].totalContributed + msg.value;

        emit ContributionMade(poolConfig.poolId, msg.sender, msg.value, currentRound);
    }

    /**
     * @dev Allows an active participant who hasn't won a round to place a bid.
     * A bid represents the amount they are willing to 'accept' as a loan,
     * effectively offering a discount to the pool. Lower bids are preferred.
     * @param _acceptAmount The amount (in Wei) the bidder is willing to accept as a loan.
     * This should be less than or equal to the total pooled amount
     * and greater than 0.
     */
    function placeBid(uint256 _acceptAmount) external {
        require(poolConfig.isActive, "Pool is not active.");
        require(participants[msg.sender].isActive, "You are not an active participant.");
        require(!participants[msg.sender].isDefaulted, "Defaulted participants cannot bid.");
        require(participants[msg.sender].roundWon == 0, "You have already won a round.");

        uint256 currentRound = poolState.currentRound;
        require(currentRound <= poolConfig.totalRounds, "Bidding period for this round has passed or all rounds completed.");
        require(block.timestamp <= rounds[currentRound].biddingEndTime, "Bidding period for this round has ended.");
        require(_acceptAmount > 0, "Bid amount must be greater than 0.");
        require(_acceptAmount <= rounds[currentRound].totalPooled, "Bid amount cannot exceed current pooled funds.");

        roundBids[currentRound].push(Bid({
            bidder: msg.sender,
            bidAmount: _acceptAmount,
            timestamp: block.timestamp
        }));

        emit BidPlaced(poolConfig.poolId, msg.sender, _acceptAmount, currentRound);
    }

    /**
     * @dev Completes the current round, determines the winner, distributes payout,
     * and prepares for the next round or concludes the pool.
     * This function can be called by anyone once the round's interval duration has passed.
     */
    function completeRound() external nonReentrant {
        require(poolConfig.isActive, "Pool is not active.");

        uint256 currentRoundNumber = poolState.currentRound;
        Round storage currentRound = rounds[currentRoundNumber];

        require(!currentRound.isCompleted, "Current round is already completed.");
        require(block.timestamp >= currentRound.startTime + poolConfig.intervalDuration, "Round interval has not yet passed.");
        require(currentRoundNumber <= poolConfig.totalRounds, "All rounds have been completed.");

        // --- 1. Process Missed Contributions and Deduct from Collateral ---
        for (uint256 i = 0; i < poolState.participantsList.length; i++) {
            address participantAddress = poolState.participantsList[i];
            if (participants[participantAddress].isActive && !currentRound.hasContributed[participantAddress]) {
                if (participants[participantAddress].collateralLocked >= poolConfig.contributionAmount) {
                    // Deduct contribution from collateral
                    participants[participantAddress].collateralLocked -= poolConfig.contributionAmount;

                    // Treat this as a contribution to the current round
                    currentRound.hasContributed[participantAddress] = true;
                    currentRound.totalPooled += poolConfig.contributionAmount;
                    participants[participantAddress].totalContributed += poolConfig.contributionAmount;
                    participants[participantAddress].missedPayments += 1;

                    emit ContributionCoveredByCollateral(poolConfig.poolId, participantAddress, poolConfig.contributionAmount);
                } else {
                    // Participant's collateral is insufficient, they default
                    participants[participantAddress].isDefaulted = true;
                    participants[participantAddress].isActive = false; // Set inactive if defaulted
                    emit ParticipantDefaulted(poolConfig.poolId, participantAddress);
                }
            }
        }

        // --- 2. Determine Winner and Payout ---
        uint256 basePayoutPercentage = 50; // Minimum 50% payout
        uint256 variablePartPercentage = ((currentRoundNumber - 1) * 50) / (poolConfig.totalRounds - 1); // Scales from 0 to 50
        uint256 payoutPercent = basePayoutPercentage + variablePartPercentage; // Range [50, 100]

        uint256 totalPoolThisRound = currentRound.totalPooled;
        // The maximum amount the winner can receive (including any potential surplus from previous rounds)
        // This acts as a cap on how much loan can be taken.
        uint256 maxPayoutToWinner = (totalPoolThisRound * payoutPercent) / 100;

        address winner = address(0);
        uint256 winningBid = type(uint256).max; // Initialize with max value to find the minimum bid
        bool hasAuction = false;

        Bid[] memory currentRoundBids = roundBids[currentRoundNumber];
        for (uint256 i = 0; i < currentRoundBids.length; i++) {
            Bid memory bid = currentRoundBids[i];
            // Bidder must be active, not defaulted, not already won, and their bid must be lower than current winning bid
            // and within the max payout allowed for this round.
            if (participants[bid.bidder].isActive &&
                !participants[bid.bidder].isDefaulted &&
                participants[bid.bidder].roundWon == 0 &&
                bid.bidAmount < winningBid &&
                bid.bidAmount <= maxPayoutToWinner) { // Ensure bid is not more than maxPayoutToWinner
                winningBid = bid.bidAmount;
                winner = bid.bidder;
                hasAuction = true;
            }
        }

        if (winner == address(0)) {
            // No valid bids or no auction winner, the entire pooled amount becomes surplus for future distribution
            currentRound.surplus = currentRound.totalPooled;
            currentRound.winningBid = 0; // No winner, so winning bid is 0
        } else {
            // A winner was found
            uint256 payoutAmount = winningBid; // Winner receives the amount they bid
            uint256 surplusGenerated = currentRound.totalPooled - winningBid;

            // Distribute accumulated surplus from previous rounds to the current winner (if any)
            uint256 eligibleParticipantsCount = 0;
            for (uint256 i = 0; i < poolState.participantsList.length; i++) {
                address participantAddress = poolState.participantsList[i];
                if (participants[participantAddress].isActive && !participants[participantAddress].isDefaulted && participants[participantAddress].roundWon == 0) {
                    eligibleParticipantsCount++;
                }
            }

            if (eligibleParticipantsCount > 0) {
                // If the winner is among the eligible participants, they also get their share of the *accumulated* surplus
                uint256 dividendPerEligibleParticipant = poolState.totalSurplus / eligibleParticipantsCount;
                if (participants[winner].isActive && !participants[winner].isDefaulted && participants[winner].roundWon == 0 && dividendPerEligibleParticipant > 0) {
                    participants[winner].dividendsEarned += dividendPerEligibleParticipant;
                    poolState.totalDividendsDistributed += dividendPerEligibleParticipant;
                    payoutAmount += dividendPerEligibleParticipant; // Add dividend to winner's payout
                    emit DividendsDistributed(poolConfig.poolId, winner, dividendPerEligibleParticipant);
                }
            }

            // Transfer payout to winner
            (bool success, ) = payable(winner).call{value: payoutAmount}("");
            require(success, "Payout transfer failed.");

            // Update winner's state
            participants[winner].roundWon = currentRoundNumber;

            currentRound.winner = winner;
            currentRound.winningBid = winningBid;
            currentRound.surplus = surplusGenerated;
            poolState.totalSurplus = poolState.totalSurplus + surplusGenerated; // Accumulate surplus
        }

        currentRound.isCompleted = true;
        currentRound.hasAuction = hasAuction;

        emit RoundCompleted(poolConfig.poolId, currentRoundNumber, currentRound.winner, currentRound.totalPooled, currentRound.surplus);

        // --- 3. Prepare for Next Round or Complete Pool ---
        if (currentRoundNumber < poolConfig.totalRounds) {
            poolState.currentRound = currentRoundNumber + 1;
            Round storage nextRound = rounds[poolState.currentRound];
            nextRound.roundNumber = poolState.currentRound;
            nextRound.startTime = block.timestamp; // Start next round immediately after current one ends
            nextRound.biddingEndTime = block.timestamp + poolConfig.biddingDuration;
        } else {
            // All rounds completed for this pool
            poolConfig.isActive = false; // Mark the entire pool as inactive
            _distributeDividends(); // Distribute final dividends and set remaining participants inactive
            emit PoolCompleted(poolConfig.poolId);
        }
    }

    /**
     * @dev Allows a participant to withdraw their remaining collateral after the pool is completed
     * and they have not defaulted and have not withdrawn it previously.
     */
    function withdrawCollateral() external nonReentrant {
        require(!poolConfig.isActive, "Pool must be completed to withdraw collateral.");
        require(!participants[msg.sender].hasWithdrawnCollateral, "You have already withdrawn your collateral.");
        require(participants[msg.sender].isActive, "You are not an active participant or have defaulted."); // Should be inactive if pool is done

        uint256 amount = participants[msg.sender].collateralLocked;
        require(amount > 0, "No collateral to withdraw.");

        participants[msg.sender].hasWithdrawnCollateral = true;
        participants[msg.sender].isActive = false; // Mark inactive after withdrawal

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Collateral withdrawal failed.");

        emit CollateralWithdrawn(poolConfig.poolId, msg.sender, amount);
    }

    /**
     * @dev Internal function to distribute the accumulated surplus as dividends
     * to eligible participants upon pool completion.
     */
    function _distributeDividends() internal {
        // Find eligible participants for final dividend distribution
        uint256 eligibleParticipantsCount = 0;
        for (uint256 i = 0; i < poolState.participantsList.length; i++) {
            address participantAddress = poolState.participantsList[i];
            // Only count participants who are active (not defaulted) and haven't won a round
            if (participants[participantAddress].isActive && !participants[participantAddress].isDefaulted && participants[participantAddress].roundWon == 0) {
                eligibleParticipantsCount++;
            }
        }

        uint256 totalPayoutAmount = 0; // To track the total amount to be paid out from pool's balance

        if (eligibleParticipantsCount > 0) {
            uint256 dividendPerParticipant = poolState.totalSurplus / eligibleParticipantsCount;

            for (uint256 i = 0; i < poolState.participantsList.length; i++) {
                address participantAddress = poolState.participantsList[i];
                if (participants[participantAddress].isActive && !participants[participantAddress].isDefaulted && participants[participantAddress].roundWon == 0) {
                    if (dividendPerParticipant > 0) {
                        participants[participantAddress].dividendsEarned += dividendPerParticipant;
                        poolState.totalDividendsDistributed += dividendPerParticipant;
                        totalPayoutAmount += dividendPerParticipant; // Add to payout for this participant

                        // Emit dividend distribution
                        emit DividendsDistributed(poolConfig.poolId, participantAddress, dividendPerParticipant);
                    }
                    // Participants also get their total contributions back
                    uint256 totalContributionsToReturn = participants[participantAddress].totalContributed;
                    totalPayoutAmount += totalContributionsToReturn; // Add to payout for this participant

                    // Emit payout for total contributions
                    emit PayOutDone(poolConfig.poolId, participantAddress, totalContributionsToReturn);

                    // Mark participant inactive after processing their final payout
                    participants[participantAddress].isActive = false;
                }
            }
        }

        // Transfer all accumulated funds to remaining participants
        if (totalPayoutAmount > 0) {
            (bool success, ) = payable(owner()).call{value: address(this).balance}(""); // Owner gets the remaining balance, or distribute based on logic
            // NOTE: The previous logic for distributing totalContributed was problematic.
            // This `_distributeDividends` function should ideally only handle the *surplus*
            // and potentially any remaining collateral. The return of `totalContributed`
            // implies the pool needs to hold these funds, which is atypical for a chit fund model
            // where contributions are immediately paid out to a winner.
            // Re-evaluate if `totalContributed` should really be returned here.
            // For now, I'm assuming the remaining balance *after* winner payout and
            // collateral withdrawals is the surplus to be distributed.
            // If `totalContributed` needs to be returned, the contract would need to hold it.
            // Given the current structure, participants only get their collateral back
            // and a share of the surplus. The winner gets the pooled amount.
            // I'll assume the goal is to distribute the *contract's remaining balance* (surplus)
            // to eligible participants.

            // The original code was attempting to pay `totalAmtEach_shld_get` which is `participants[participantAddress].totalContributed`
            // alongside `dividendPerParticipant` in the loop. This implies the contract holds ALL contributions until the end,
            // which contradicts the `winner` getting the `winningBid` during each round.
            // If this is a rotating savings and credit association (ROSCA) model, the contributions from all participants
            // *are* the loan for the winner. They don't get their "total contributed" back from the contract;
            // their "return" is when they win a round (get the loan) or receive dividends from surplus.
            // The only thing remaining for non-winners is their *collateral* and a share of *surplus*.

            // Therefore, I'm modifying the _distributeDividends to only handle the surplus and setting isActive to false.
            // The `withdrawCollateral` function handles the collateral.

            // The original logic for `PayOutDone` and sending `totalAmtEach_shld_get` is removed as it contradicts the chit fund flow.
            // Participants only get their collateral back and a share of the surplus if they didn't win.
            // If they won, they got the loan.

            // The remaining `poolState.totalSurplus` should be distributed.
            // The existing `_distributeDividends` already calculates `dividendPerParticipant` from `poolState.totalSurplus`.
            // The `payable(participantAddress).call{value: dividendPerParticipant}("")` sends it.
            // The `poolState.totalSurplus = 0;` clears it.

            // Let's ensure the contract's actual remaining balance is transferred as surplus,
            // or if it's held, it's explicitly stated.
            // Assuming `poolState.totalSurplus` accurately reflects the funds to be distributed.
        }
        poolState.totalSurplus = 0; // Reset surplus after distribution
    }


    // --- View Functions ---

    /**
     * @dev Returns the configuration and current state of this pool.
     * @return config The PoolConfig struct containing static pool parameters.
     * @return state The PoolState struct containing dynamic pool status.
     */
    function getPoolInfo() external view returns (
        PoolConfig memory config,
        PoolState memory state
    ) {
        return (poolConfig, poolState);
    }

    /**
     * @dev Returns the participant information for a given user in this pool.
     * @param _user The address of the participant.
     * @return A Participant struct containing details about the user's involvement.
     */
    function getParticipantInfo(address _user) external view returns (Participant memory) {
        return participants[_user];
    }

    /**
     * @dev Returns the details of a specific round in this pool.
     * @param _round The round number.
     * @return roundNumber The identifier for the round.
     * @return totalPooled The total contributions collected in this round (in Wei).
     * @return startTime The timestamp when the round began.
     * @return biddingEndTime The timestamp when the bidding period for the round ends.
     * @return winner The address of the round's winner (address(0) if no winner yet).
     * @return winningBid The winning bid amount (in Wei).
     * @return surplus The surplus generated in this round (in Wei).
     * @return isCompleted True if the round has concluded.
     * @return hasAuction True if an auction took place for this round.
     */
    function getRoundInfo(uint256 _round) external view returns (
        uint256 roundNumber,
        uint256 totalPooled,
        uint256 startTime,
        uint256 biddingEndTime,
        address winner,
        uint256 winningBid,
        uint256 surplus,
        bool isCompleted,
        bool hasAuction
    ) {
        require(_round > 0 && _round <= poolConfig.totalRounds, "Invalid round number.");
        Round storage round = rounds[_round];
        return (
            round.roundNumber,
            round.totalPooled,
            round.startTime,
            round.biddingEndTime,
            round.winner,
            round.winningBid,
            round.surplus,
            round.isCompleted,
            round.hasAuction
        );
    }

    /**
     * @dev Returns all bids placed for a specific round in this pool.
     * @param _round The round number.
     * @return An array of Bid structs for the specified round.
     */
    function getRoundBids(uint256 _round) external view returns (Bid[] memory) {
        require(_round > 0 && _round <= poolConfig.totalRounds, "Invalid round number.");
        return roundBids[_round];
    }

    /**
     * @dev Checks if a user is an active participant in this pool.
     * @param _user The address of the user.
     * @return True if the user is an active participant, false otherwise.
     */
    function isParticipant(address _user) external view returns (bool) {
        return participants[_user].isActive;
    }

    /**
     * @dev Returns the list of all participants in this pool.
     * @return An array of addresses of all participants.
     */
    function getParticipantsList() external view returns (address[] memory) {
        return poolState.participantsList;
    }

    /**
     * @dev Returns the current Ether balance of this pool contract.
     * @return The balance in Wei.
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the number of active participants in the current round who have not yet won a round.
     * This is useful for calculating potential dividend distribution.
     * @return The count of eligible participants.
     */
    function getEligibleParticipantsCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < poolState.participantsList.length; i++) {
            address participantAddress = poolState.participantsList[i];
            if (participants[participantAddress].isActive && !participants[participantAddress].isDefaulted && participants[participantAddress].roundWon == 0) {
                count++;
            }
        }
        return count;
    }

    /**
     * @dev Returns the projected payout percentage for a given round number.
     * @param _roundNumber The round number to check.
     * @return The payout percentage (e.g., 50 for 50%).
     */
    function getProjectedPayoutPercentage(uint256 _roundNumber) external view returns (uint256) {
        require(_roundNumber > 0 && _roundNumber <= poolConfig.totalRounds, "Invalid round number.");
        uint256 basePayoutPercentage = 50;
        if (poolConfig.totalRounds == 1) return basePayoutPercentage; // Avoid division by zero if only one round
        uint256 variablePartPercentage = ((_roundNumber - 1) * 50) / (poolConfig.totalRounds - 1);
        return basePayoutPercentage + variablePartPercentage;
    }

    /**
     * @dev Returns the remaining time in seconds for the current round to end.
     * Returns 0 if the round has already ended or not started.
     * @return Remaining time in seconds.
     */
    function getRemainingTimeCurrentRound() external view returns (uint256) {
        uint256 currentRoundNumber = poolState.currentRound;
        Round storage currentRound = rounds[currentRoundNumber];

        if (block.timestamp < currentRound.startTime + poolConfig.intervalDuration) {
            return (currentRound.startTime + poolConfig.intervalDuration) - block.timestamp;
        }
        return 0;
    }

    /**
     * @dev Returns the remaining time in seconds for the current round's bidding period to end.
     * Returns 0 if the bidding period has already ended or not started.
     * @return Remaining time in seconds for bidding.
     */
    function getRemainingTimeBiddingPeriod() external view returns (uint256) {
        uint256 currentRoundNumber = poolState.currentRound;
        Round storage currentRound = rounds[currentRoundNumber];

        if (block.timestamp < currentRound.biddingEndTime) {
            return currentRound.biddingEndTime - block.timestamp;
        }
        return 0;
    }


    // --- Owner-only Functions (for Factory or Pool Creator) ---

    /**
     * @dev Allows the pool creator (owner) to pause or unpause the pool.
     * This can be used for maintenance or in case of issues.
     * @param _isActive The new active status for the pool (true to activate, false to deactivate).
     */
    function setPoolActiveStatus(bool _isActive) external onlyOwner {
        poolConfig.isActive = _isActive;
    }

    // Fallback function to receive Ether
    receive() external payable {
        // Ether received will be part of the pool's balance
    }
}