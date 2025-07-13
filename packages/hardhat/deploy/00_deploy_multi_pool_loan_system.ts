import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a single instance of the "MultiPoolLoanSystem" contract.
 *
 * This script is for directly deploying a MultiPoolLoanSystem contract,
 * without using a factory. Useful for initial testing and UI integration.
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployMultiPoolLoanSystem: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    console.log("----------------------------------------------------");
    console.log("🚀 Deploying MultiPoolLoanSystem directly...");

    // Define the constructor arguments for MultiPoolLoanSystem
    // These are example values; adjust them as needed for your testing
    const _poolId = 1; // Since we're deploying directly, we'll assign a fixed ID for this instance.
    const _contributionAmount = hre.ethers.parseEther("0.01"); // 0.01 ETH per contribution
    const _collateralAmount = hre.ethers.parseEther("0.1");   // 0.1 ETH collateral
    const _totalRounds = 3;
    const _intervalDuration = 60;
    const _biddingDuration = 30;
    const _maxParticipants = 3;
    const _poolCreator = deployer; // The deployer will be the owner/creator of this single pool

    const multiPoolLoanSystemDeployment = await deploy("MultiPoolLoanSystem", {
        from: deployer,
        args: [
            _poolId,
            _contributionAmount,
            _collateralAmount,
            _totalRounds,
            _intervalDuration,
            _biddingDuration,
            _maxParticipants,
            _poolCreator,
        ],
        log: true,
        autoMine: true, // Automatically mine the transaction for local development
    });

    console.log(`✅ MultiPoolLoanSystem deployed to: ${multiPoolLoanSystemDeployment.address}`);
    console.log("----------------------------------------------------");

    // Optional: Get the deployed contract to verify some initial state
    const deployedContract = new Contract(
        multiPoolLoanSystemDeployment.address,
        multiPoolLoanSystemDeployment.abi,
        await hre.ethers.getSigner(deployer)
    );

    const poolConfig = await deployedContract.poolConfig();
    console.log("Initial Pool Config:");
    console.log(`  Pool ID: ${poolConfig.poolId.toString()}`);
    console.log(`  Contribution Amount: ${hre.ethers.formatEther(poolConfig.contributionAmount)} ETH`);
    console.log(`  Collateral Amount: ${hre.ethers.formatEther(poolConfig.collateralAmount)} ETH`);
    console.log(`  Total Rounds: ${poolConfig.totalRounds.toString()}`);
    console.log(`  Max Participants: ${poolConfig.maxParticipants.toString()}`);
    console.log(`  Is Active: ${poolConfig.isActive}`);
    console.log(`  Creator: ${poolConfig.creator}`);
    console.log(`  Creation Time: ${new Date(Number(poolConfig.creationTime) * 1000).toLocaleString()}`);
};

export default deployMultiPoolLoanSystem;

deployMultiPoolLoanSystem.tags = ["MultiPoolLoanSystem"]; // Corrected tag to match contract name