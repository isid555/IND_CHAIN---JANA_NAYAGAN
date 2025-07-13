import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

const deployRemittance: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    console.log("----------------------------------------------------");
    console.log("Deploying Remittance...");

    const remittanceDeployment = await deploy("Remittance", {
        from: deployer,
        args: [], // No constructor arguments for Remittance
        log: true,
        autoMine: true, // Speed up deployment on local networks
    });

    const remittance = await ethers.getContractAt(
        "Remittance",
        remittanceDeployment.address
    );

    // console.log(`Remittance deployed to: ${remittance.address}`);
    console.log("----------------------------------------------------");

    // --- Test Remittance Sending ---
    console.log("\nAttempting to send a test remittance...");

    const testRecipientAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Example recipient

    // --- GENERATE A UNIQUE SECRET PHRASE FOR EACH DEPLOYMENT ---
    const uniqueTestSecretPhrase = `super_secret_key_for_test_${Date.now()}`; // Appends current timestamp

    // Calculate the payment ID using the recipient and the unique secret phrase
    const calculatedTestPaymentId = ethers.keccak256(
        ethers.toUtf8Bytes(testRecipientAddress + uniqueTestSecretPhrase)
    );

    console.log(`Test Recipient: ${testRecipientAddress}`);
    console.log(`Test Secret Phrase (unique): ${uniqueTestSecretPhrase}`); // For debugging
    console.log(`Calculated Test Payment ID: ${calculatedTestPaymentId}`);

    const testAmount = ethers.parseEther("0.02"); // 0.02 ETH
    const testDescription = "Birthday gift from deploy script";

    try {
        // Check if the payment ID already exists to provide better feedback
        // This check is for the deploy script's robustness, not required by the contract
        const existingRemittance = await remittance.remittances(calculatedTestPaymentId);
        if (existingRemittance.amount.toString() !== "0") {
            console.log(`Warning: Payment ID ${calculatedTestPaymentId} already exists with amount ${ethers.formatEther(existingRemittance.amount)} ETH. Skipping send test remittance.`);
            // You might want to throw an error or handle this differently based on your test goals
            return;
        }

        const sendTx = await remittance.sendRemittance(
            testRecipientAddress,
            calculatedTestPaymentId,
            testDescription,
            { value: testAmount, from: deployer } // Explicitly specify sender if needed
        );
        console.log(`Transaction sent to send remittance (hash: ${sendTx.hash})`);
        await sendTx.wait(); // Wait for the transaction to be mined
        console.log("Test remittance sent successfully!");

        // Retrieve and log the details of the sent remittance
        const sentRemittanceDetails = await remittance.remittances(calculatedTestPaymentId);
        console.log("\n--- Sent Remittance Details ---");
        console.log(`  Sender: ${sentRemittanceDetails.sender}`);
        console.log(`  Recipient: ${sentRemittanceDetails.recipient}`);
        console.log(`  Amount: ${ethers.formatEther(sentRemittanceDetails.amount)} ETH`);
        console.log(`  Withdrawn: ${sentRemittanceDetails.withdrawn}`);
        console.log(`  Description: ${sentRemittanceDetails.description}`);
        console.log("-------------------------------");

    } catch (error: any) {
        console.error("Failed to send test remittance in deploy script:", error.message);
        if (error.data) {
            console.error("Revert data:", error.data);
        }
    } finally {
        console.log("Deployment script for Remittance finished.");
        console.log("----------------------------------------------------");
    }
};

export default deployRemittance;
deployRemittance.tags = ["Remittance"];