import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const myToken = buildModule("myToken", (m) => {

    const erc20 = m.contract("myToken");

    return { erc20 };
});

export default myToken;
