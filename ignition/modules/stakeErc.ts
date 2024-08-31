import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = " ";
const DEFAULT_WITHDRAW_DEADLINE = 60 * 60 * 24 * 30;

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {
  const withdrawDeadline = m.getParameter("withdrawDeadline", DEFAULT_WITHDRAW_DEADLINE);

    const stake = m.contract("StakeERC20", [tokenAddress, withdrawDeadline]);

    return { stake };
});

export default StakeERC20Module;