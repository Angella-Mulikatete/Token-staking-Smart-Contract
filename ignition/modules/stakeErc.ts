import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = " ";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {

    const stake = m.contract("StakeERC20", [tokenAddress]);

    return { stake };
});

export default StakeERC20Module;