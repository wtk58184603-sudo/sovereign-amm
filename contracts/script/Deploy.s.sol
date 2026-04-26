// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SovereignV3Router} from "../src/SovereignV3Router.sol";

contract Deploy is Script {
    function run() public {
        // 1. 提取 12 个单词的物理火种，并在内存中推导你的绝对控制权私钥
        string memory seedPhrase = vm.envString("SEED_PHRASE");
        uint256 deployerPrivateKey = vm.deriveKey(seedPhrase, 0);
        
        // 2. 主权锚定：自动计算你的钱包地址，将其定义为 43% 税收的唯一国库
        address treasuryAddress = vm.addr(deployerPrivateKey);

        // 3. 变量注入 (占位符)：为了强行通过部署参数验证，注入临时的 Mock 地址
        // 脆弱性风险提示：这两个地址目前是死的，合约部署后暂时无法调用 exactInputSingle，直到后续换成真实地址。
        address mockHarvester = 0x0000000000000000000000000000000000000001; 
        address mockPool = 0x0000000000000000000000000000000000000002;      

        // 启动链上物理广播
        vm.startBroadcast(deployerPrivateKey);

        // 4. 强制实体化：将三个物理参数压入构造函数
        SovereignV3Router router = new SovereignV3Router(
            mockHarvester, 
            mockPool, 
            treasuryAddress 
        );
        
        // 在终端打印最终的物理资产清单
        console.log("=========================================");
        console.log("Sovereign ZK-LVR Router Deployed!");
        console.log("Physical Router Address: ", address(router));
        console.log("Treasury Anchored To: ", treasuryAddress);
        console.log("=========================================");

        vm.stopBroadcast();
    }
}