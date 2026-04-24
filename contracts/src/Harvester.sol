// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Harvester {
    uint256 public constant MAX_FEE_IMPACT = 10000; 
    uint256 public constant MAX_PROOF_AGE = 60; 

    uint64 public currentDynamicFee;
    uint256 public lastUpdateTimestamp;

    event HarvestExecuted(uint64 newFee, uint256 timestamp);

    function executeHarvest(
        bytes calldata publicValues, 
        bytes calldata proofBytes, 
        uint256 proofTimestamp
    ) external {
        require(block.timestamp <= proofTimestamp + MAX_PROOF_AGE, "SYSTEM HALTED: Stale proof!");
        require(proofBytes.length == 32, "SYSTEM HALTED: Invalid mock proof!");
        require(publicValues.length == 24, "SYSTEM HALTED: Invalid payload length!");

        // 命名修正：Le
        uint64 finalDynamicFee = readUint64Le(publicValues, 16);

        require(finalDynamicFee <= MAX_FEE_IMPACT, "SYSTEM HALTED: Circuit Breaker!");

        currentDynamicFee = finalDynamicFee;
        lastUpdateTimestamp = block.timestamp;

        emit HarvestExecuted(currentDynamicFee, lastUpdateTimestamp);
    }

    // 命名修正：Le。修復 Warning 3149：強制同級別類型位移
    function readUint64Le(bytes calldata data, uint256 offset) internal pure returns (uint64) {
        uint64 result;
        for (uint256 i = 0; i < 8; i++) {
            result |= uint64(uint256(uint8(data[offset + i])) << (i * 8));
        }
        return result;
    }
}