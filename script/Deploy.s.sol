// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SovereignV3Router} from "../src/SovereignV3Router.sol";

contract Deploy is Script {
    function run() public {
        // 從 .env 提取 12 個單字的物理火種
        string memory seedPhrase = vm.envString("SEED_PHRASE");
        
        // 動用 Foundry 底層作弊碼，在內存中強制推導並解鎖真實私鑰 (index 0)
        uint256 deployerPrivateKey = vm.deriveKey(seedPhrase, 0);
        
        address sp1Verifier = vm.envAddress("SP1_VERIFIER_ADDRESS");

        // 啟動鏈上廣播
        vm.startBroadcast(deployerPrivateKey);

        SovereignV3Router router = new SovereignV3Router(sp1Verifier);
        
        console.log("=========================================");
        console.log("Sovereign ZK-LVR Router Deployed!");
        console.log("Physical Address: ", address(router));
        console.log("=========================================");

        vm.stopBroadcast();
    }
}