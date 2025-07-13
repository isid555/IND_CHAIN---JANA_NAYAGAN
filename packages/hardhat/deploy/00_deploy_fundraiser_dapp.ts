// deploy/00_deploy_fundraiser_dapp.ts
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers"; // ethers v6 Contract class
import { parseEther, formatEther, Interface, toUtf8Bytes } from "ethers"; // Import ethers v6 utilities

/**
 * @dev Deploys the FundraiserDApp contract and demonstrates creating a test fundraiser.
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployFundraiserDApp: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    console.log("----------------------------------------------------");
    console.log("Deploying FundraiserDApp...");

    const fundraiserDAppDeployment = await deploy("FundraiserDApp", {
        from: deployer,
        args: [], // FundraiserDApp constructor doesn't take any arguments
        log: true,
        autoMine: true, // Speeds up deployment on local networks
    });

    console.log("FundraiserDApp deployed to:", fundraiserDAppDeployment.address);
    console.log("----------------------------------------------------");

    // Get the deployed contract instance to interact with it after deploying
    const fundraiserDApp: Contract = new Contract(
        fundraiserDAppDeployment.address,
        fundraiserDAppDeployment.abi,
        await hre.ethers.getSigner(deployer) // Get a signer for the deployer to send transactions
    );

    // --- Example: Interact with the deployed FundraiserDApp contract ---

    // 1. Call a view function on the contract
    try {
        const initialTotalFundraisers: bigint = await fundraiserDApp.getTotalFundraisers();
        console.log(`Initial total fundraisers: ${initialTotalFundraisers.toString()}`);
    } catch (error: any) {
        console.error("Failed to read initial total fundraisers:", error);
    }

    // 2. Create a test fundraiser immediately after deployment (optional)
    console.log("\nAttempting to create a test fundraiser...");
    try {
        const tx = await fundraiserDApp.createFundraiser(
            "My Test Campaign for Local Charity", // _name
            "Helping local communities with essential supplies.", // _description
            "QmTestIPFSHash12345", // _ipfsHash (dummy)
            parseEther("0.5"), // _amountNeeded (0.5 ETH) - returns bigint
            BigInt(3600 * 24 * 7) // _timeLimitInSeconds (7 days) - use BigInt for large numbers
        );
        console.log(`Transaction sent to create fundraiser (hash: ${tx.hash})`);
        await tx.wait(); // Wait for the transaction to be mined
        console.log("Test fundraiser created successfully!");

        // 3. Verify updated total fundraisers
        const updatedTotalFundraisers: bigint = await fundraiserDApp.getTotalFundraisers();
        console.log(`Total fundraisers after test campaign: ${updatedTotalFundraisers.toString()}`);

        // 4. Parse the event from the transaction receipt to get the new fundraiser's details
        const receipt = await hre.ethers.provider.getTransactionReceipt(tx.hash);
        if (receipt && receipt.logs) {
            const contractInterface: Interface = new Interface(fundraiserDAppDeployment.abi);
            for (const log of receipt.logs) {
                try {
                    const parsedLog = contractInterface.parseLog(log);
                    if (parsedLog && parsedLog.name === "FundraiserCreated") {
                        // FIX: Cast to unknown first, then to the specific tuple type
                        const [id, owner, name, amountNeeded, deadline, ipfsHash] = parsedLog.args as unknown as [
                            bigint,
                            string,
                            string,
                            bigint,
                            bigint,
                            string
                        ];
                        // Current time is Saturday, July 12, 2025 at 8:55:37 PM IST.
                        // Remember the current location is Bengaluru, Karnataka, India.
                        console.log(`
                            --- FundraiserCreated Event Details ---
                            ID:            ${id}
                            Owner:         ${owner}
                            Name:          ${name}
                            Amount Needed: ${formatEther(amountNeeded)} ETH
                            Deadline:      ${new Date(Number(deadline) * 1000).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })} (Bengaluru time)
                            IPFS Hash:     ${ipfsHash}
                            ---------------------------------------
                        `);
                    }
                } catch (e: any) {
                    // Ignore logs not from this contract or not parsable
                }
            }
        }
    } catch (error: any) {
        console.error("Failed to create test fundraiser in deploy script:", error);
        if (error.reason) console.error("Revert reason:", error.reason);
        if (error.data) console.error("Revert data:", error.data);
    }
    console.log("\nDeployment script for FundraiserDApp finished.");
    console.log("----------------------------------------------------");
};

export default deployFundraiserDApp;

deployFundraiserDApp.tags = ["FundraiserDApp"];