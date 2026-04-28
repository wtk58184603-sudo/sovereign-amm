// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SovereignV3Router} from "../src/SovereignV3Router.sol";
import {Harvester} from "../src/Harvester.sol";

contract DeployV4 is Script {
    function run() public {
        string memory seedPhrase = vm.envString("SEED_PHRASE");
        uint256 deployerPrivateKey = vm.deriveKey(seedPhrase, 0);
        address treasuryAddress = vm.addr(deployerPrivateKey);

        // 變量注入：SP1 測試網官方 Verifier (即使我們用 Mock，合約層面依然對齊標準)
        address sp1TestnetVerifier = 0x3B6041173B80E77f038f3F2C0f9744f04837185e; 
        bytes32 dummyVKey = bytes32(0); // 測試印記
        address mockPool = 0x0000000000000000000000000000000000000002;

        vm.startBroadcast(deployerPrivateKey);

        // 第一擊：實體化真大腦
        Harvester harvester = new Harvester(sp1TestnetVerifier, dummyVKey);

        // 第二擊：實體化新收費站，將剛誕生的真大腦 CA 物理注入
        SovereignV3Router router = new SovereignV3Router(
            address(harvester),
            mockPool,
            treasuryAddress
        );

        console.log("=========================================");
        console.log("Phase 5: Neural Link Established!");
        console.log("Harvester Brain CA: ", address(harvester));
        console.log("Sovereign Router CA:", address(router));
        console.log("=========================================");

        vm.stopBroadcast();
    }
}