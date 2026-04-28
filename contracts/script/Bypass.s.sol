// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

// 1. 打造一個瞎子雷達：無論收到什麼證明，都直接放行 (不寫任何 require 邏輯)
contract MockVerifier {
    function verifyProof(bytes32, bytes calldata, bytes calldata) external pure {
        // 絕對放行
    }
}

// 宣告大腦的介面
interface IHarvester {
    function setVerifier(address _newVerifier) external;
}

contract Bypass is Script {
    function run() public {
        // 讀取你的 12 個單詞火種
        string memory seed = vm.envString("SEED_PHRASE");
        uint256 deployerPrivateKey = vm.deriveKey(seed, 0);

        vm.startBroadcast(deployerPrivateKey);

        // 2. 將瞎子雷達實體化
        MockVerifier mockV = new MockVerifier();

        // 3. 鎖定真大腦的實體座標，並動用主權權限替換它的雷達
        IHarvester brain = IHarvester(0x91430ed99E2dE483B8a64a8D34441F03FC7a32a0);
        brain.setVerifier(address(mockV));

        console.log("=========================================");
        console.log("Hijack Complete: Blind Radar Installed.");
        console.log("Mock Verifier CA: ", address(mockV));
        console.log("=========================================");

        vm.stopBroadcast();
    }
}