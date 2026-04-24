// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SovereignV3Router} from "../src/SovereignV3Router.sol";

contract DeploySovereign is Script {
    function run() external {
        // 物理隔離讀取：嚴禁在此處寫入真實私鑰與地址
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address treasury = vm.envAddress("TREASURY_ADDRESS");
        address targetPool = vm.envAddress("UNISWAP_V3_POOL");
        
        // 實戰合規化校準：接入 SP1 官方驗證器地址
        address verifier = vm.envAddress("SP1_VERIFIER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // 直接部署收費站，注入官方驗證器座標
        SovereignV3Router router = new SovereignV3Router(
            verifier,
            targetPool,
            treasury
        );
        
        console.log("SovereignV3Router Deployed with Verifier:", verifier);
        console.log("Deployed at:", address(router));

        vm.stopBroadcast();
    }
}