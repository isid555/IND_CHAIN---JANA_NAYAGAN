// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Remittance {
    // Event emitted when a remittance is sent
    event RemittanceSent(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        bytes32 indexed paymentId,
        string description // Added description to the event
    );

    // Event emitted when a remittance is withdrawn
    event RemittanceWithdrawn(
        address indexed recipient,
        uint256 amount,
        bytes32 indexed paymentId
    );


    mapping(bytes32 => RemittanceDetails) public remittances;


    struct RemittanceDetails {
        address sender;
        address recipient;
        uint256 amount;
        bool withdrawn;
        string description; // Added description to the struct
    }


    function sendRemittance(address _recipient, bytes32 _paymentId, string memory _description) public payable {
        // Ensure that the amount sent is greater than zero
        require(msg.value > 0, "Remittance amount must be greater than zero.");
        // Ensure that the paymentId is unique and has not been used before
        require(remittances[_paymentId].amount == 0, "Payment ID already exists or is in use.");
        // Ensure the recipient is a valid address
        require(_recipient != address(0), "Recipient address cannot be zero.");

        // Store the remittance details, including the new description
        remittances[_paymentId] = RemittanceDetails({
            sender: msg.sender,
            recipient: _recipient,
            amount: msg.value,
            withdrawn: false,
            description: _description // Store the description
        });

        // Emit the RemittanceSent event, including the description
        emit RemittanceSent(msg.sender, _recipient, msg.value, _paymentId, _description);
    }


    function withdrawRemittance(string memory _secretPhrase) public {
        // Generate the paymentId from the recipient's address and the provided secret phrase
        bytes32 paymentId = keccak256(abi.encodePacked(msg.sender, _secretPhrase));

        // Retrieve the remittance details
        RemittanceDetails storage remittance = remittances[paymentId];

        // Ensure the remittance exists and belongs to the caller
        require(remittance.amount > 0, "Remittance does not exist.");
        require(remittance.recipient == msg.sender, "You are not the intended recipient.");
        // Ensure the remittance has not been withdrawn yet
        require(!remittance.withdrawn, "Remittance has already been withdrawn.");

        // Mark the remittance as withdrawn
        remittance.withdrawn = true;

        // Transfer the ETH to the recipient
        (bool success, ) = payable(msg.sender).call{value: remittance.amount}("");
        require(success, "Failed to send ETH to recipient.");

        // Emit the RemittanceWithdrawn event
        emit RemittanceWithdrawn(msg.sender, remittance.amount, paymentId);

        // Optionally, delete the remittance entry to save gas, but this might remove historical data
        // delete remittances[paymentId];
    }


    function calculatePaymentId(address _recipient, string memory _secretPhrase)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_recipient, _secretPhrase));
    }
}