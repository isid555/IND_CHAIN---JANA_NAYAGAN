// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FundraiserDApp
 * @dev A smart contract for creating and managing fundraising campaigns.
 * Users can create campaigns, donate Ether, and campaign owners can withdraw
 * funds once the goal is met or the deadline passes.
 */
contract FundraiserDApp {

    struct Fundraiser {
        address payable owner;         // The address of the campaign creator
        string name;                   // Name of the fundraiser
        string description;            // Detailed description of the fundraiser
        string ipfsHash;               // IPFS hash of an associated document (e.g., PDF)
        uint256 amountNeeded;          // Target amount in Wei (1 Ether = 10^18 Wei)
        uint256 amountRaised;          // Current amount raised in Wei
        uint256 deadline;              // Unix timestamp when the campaign ends
        bool active;                   // True if the campaign is active, false otherwise
    }

    mapping(uint256 => Fundraiser) public fundraisers;

    uint256 public nextFundraiserId;

    // Events to notify off-chain applications about state changes
    event FundraiserCreated(
        uint256 indexed id,
        address indexed owner,
        string name,
        uint256 amountNeeded,
        uint256 deadline,
        string ipfsHash
    );
    event DonationReceived(
        uint256 indexed fundraiserId,
        address indexed donor,
        uint256 amount
    );
    event FundsWithdrawn(
        uint256 indexed fundraiserId,
        address indexed owner,
        uint256 amount
    );

    function createFundraiser(
        string memory _name,
        string memory _description,
        string memory _ipfsHash,
        uint256 _amountNeeded,
        uint256 _timeLimitInSeconds
    ) public {
        require(_amountNeeded > 0, "Amount needed must be greater than zero.");
        require(_timeLimitInSeconds > 0, "Time limit must be greater than zero.");

        // Calculate the deadline timestamp
        uint256 _deadline = block.timestamp + _timeLimitInSeconds;

        // Create a new Fundraiser struct
        fundraisers[nextFundraiserId] = Fundraiser({
            owner: payable(msg.sender),
            name: _name,
            description: _description,
            ipfsHash: _ipfsHash,
            amountNeeded: _amountNeeded,
            amountRaised: 0,
            deadline: _deadline,
            active: true
        });

        // Emit an event for off-chain listeners
        emit FundraiserCreated(
            nextFundraiserId,
            msg.sender,
            _name,
            _amountNeeded,
            _deadline,
            _ipfsHash
        );

        nextFundraiserId++;
    }

    function donate(uint256 _fundraiserId) public payable {

        require(_fundraiserId < nextFundraiserId, "Fundraiser does not exist.");

        require(fundraisers[_fundraiserId].active, "Fundraiser is not active.");

        require(block.timestamp < fundraisers[_fundraiserId].deadline, "Fundraiser has ended.");

        require(msg.value > 0, "Donation amount must be greater than zero.");


        fundraisers[_fundraiserId].amountRaised += msg.value;


        emit DonationReceived(_fundraiserId, msg.sender, msg.value);


        if (fundraisers[_fundraiserId].amountRaised >= fundraisers[_fundraiserId].amountNeeded) {
            fundraisers[_fundraiserId].active = false;
        }
    }


    function withdrawFunds(uint256 _fundraiserId) public {

        require(_fundraiserId < nextFundraiserId, "Fundraiser does not exist.");

        Fundraiser storage fundraiser = fundraisers[_fundraiserId];


        require(msg.sender == fundraiser.owner, "Only the fundraiser owner can withdraw funds.");

        // Funds can be withdrawn if:
        // 1. The deadline has passed OR
        // 2. The target amount has been reached (even if the deadline hasn't passed)
        require(
            block.timestamp >= fundraiser.deadline || fundraiser.amountRaised >= fundraiser.amountNeeded,
            "Withdrawal conditions not met: deadline not passed and target not reached."
        );


        require(fundraiser.amountRaised > 0, "No funds to withdraw.");

        uint256 amountToWithdraw = fundraiser.amountRaised;
        fundraiser.amountRaised = 0;
        fundraiser.active = false;


        (bool success, ) = fundraiser.owner.call{value: amountToWithdraw}("");
        require(success, "Failed to send Ether to owner.");


        emit FundsWithdrawn(_fundraiserId, msg.sender, amountToWithdraw);
    }


    function getFundraiserDetails(uint256 _fundraiserId)
        public
        view
        returns (
            address owner,
            string memory name,
            string memory description,
            string memory ipfsHash,
            uint256 amountNeeded,
            uint256 amountRaised,
            uint256 deadline,
            bool active
        )
    {
        require(_fundraiserId < nextFundraiserId, "Fundraiser does not exist.");
        Fundraiser storage fundraiser = fundraisers[_fundraiserId];
        return (
            fundraiser.owner,
            fundraiser.name,
            fundraiser.description,
            fundraiser.ipfsHash,
            fundraiser.amountNeeded,
            fundraiser.amountRaised,
            fundraiser.deadline,
            fundraiser.active
        );
    }

    function getTotalFundraisers() public view returns (uint256) {
        return nextFundraiserId;
    }
}