import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers"; // Make sure this import is present

/**
 * Deploys a contract named "MultiPoolLoanSystemFactory" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    const factoryDeployment = await deploy("MultiPoolLoanSystemFactory", {
        from: deployer,
        args: [deployer],
        log: true,
        autoMine: true,
    });

    console.log("MultiPoolLoanSystemFactory deployed to:", factoryDeployment.address);

    // Get the deployed contract to interact with it after deploying
    const multiPoolLoanSystemFactory = new Contract(
        factoryDeployment.address,
        factoryDeployment.abi,
        await hre.ethers.getSigner(deployer) // Get a signer for the deployer
    );

    // Example: You can now call a view function on the factory
    const totalPools = await multiPoolLoanSystemFactory.getTotalPoolsCreated();
    console.log("Total pools created (initially 0):", totalPools.toString());

    // Example: Create a test pool immediately after deployment (optional)
    // This will create a new MultiPoolLoanSystem contract
    // Note: Ensure the arguments match your contract's createPool function
    try {
        const tx = await multiPoolLoanSystemFactory.createPool(
            hre.ethers.parseEther("0.01"), // _contributionAmount (e.g., 0.01 ETH)
            hre.ethers.parseEther("0.1"),  // _collateralAmount (e.g., 0.1 ETH)
            10,                            // _totalRounds
            3600,                          // _intervalDuration (1 hour)
            600,                           // _biddingDuration (10 minutes)
            5                              // _maxParticipants
        );
        await tx.wait();
        console.log("Test pool created by deploy script.");

        const updatedTotalPools = await multiPoolLoanSystemFactory.getTotalPoolsCreated();
        console.log("Total pools created (after test pool):", updatedTotalPools.toString());

        // You can also parse the event from the transaction receipt to get the new pool's address
        const receipt = await hre.ethers.provider.getTransactionReceipt(tx.hash);
        if (receipt && receipt.logs) {
            const factoryInterface = new hre.ethers.Interface(factoryDeployment.abi);
            for (const log of receipt.logs) {
                try {
                    const parsedLog = factoryInterface.parseLog(log);
                    if (parsedLog && parsedLog.name === "PoolCreated") {
                        const [poolId, creator, poolAddress, contributionAmount, maxParticipants] = parsedLog.args;
                        console.log(`New Pool Created: ID=${poolId}, Address=${poolAddress}, Creator=${creator}`);
                    }
                } catch (e) {
                    // Ignore logs that are not from this contract or not parsable
                }
            }
        }

    } catch (error) {
        console.error("Failed to create test pool in deploy script:", error);
    }
};

export default deployYourContract;

deployYourContract.tags = ["MultiPoolLoanSystemFactory"]; // Corrected tag to match contract name