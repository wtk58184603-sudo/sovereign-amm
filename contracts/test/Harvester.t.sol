// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 修復引入警告：強制具名引入
import {Test} from "forge-std/Test.sol";
import {Harvester} from "../src/Harvester.sol";

contract HarvesterTest is Test {
    Harvester public harvester;

    function setUp() public {
        harvester = new Harvester();
    }

    function testHarvestExecution() public {
        bytes memory publicValues = hex"005ed0b200000000804ecbb500000000b414000000000000";
        bytes memory mockProof = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        
        harvester.executeHarvest(publicValues, mockProof, block.timestamp);

        assertEq(harvester.currentDynamicFee(), 5300);
    }

    function testStaleProofRevert() public {
        bytes memory publicValues = hex"005ed0b200000000804ecbb500000000b414000000000000";
        bytes memory mockProof = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

        vm.expectRevert("SYSTEM HALTED: Stale proof!");
        harvester.executeHarvest(publicValues, mockProof, block.timestamp - 61);
    }
}