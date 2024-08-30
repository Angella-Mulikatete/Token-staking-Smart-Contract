import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DEFAULT_WITHDRAW_DEADLINE = 60 * 60 * 24 * 30; // 30 days in seconds
const DEFAULT_REWARD_RATE: bigint = 1_000_000_000n; 

const StakeEthModule = buildModule("StakeEthModule", (m) => {
  // Parameters for deployment
  const withdrawDeadline = m.getParameter("withdrawDeadline", DEFAULT_WITHDRAW_DEADLINE);
  const rewardRate = m.getParameter("rewardRate", DEFAULT_REWARD_RATE);

  // Deploy the StakeEth contract with the provided parameters
  const stakeEth = m.contract("StakeEth", [withdrawDeadline, rewardRate]);

  return { stakeEth };
});

export default StakeEthModule;


// Deployed SaveERC20: 0xD410219f5C87247d3F109695275A70Da7805f1b1
