// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// SP1 官方驗證器介面 (系統辨識真偽的唯一雷達)
interface ISP1Verifier {
    function verifyProof(bytes32 programVKey, bytes calldata publicValues, bytes calldata proofBytes) external view;
}

contract Harvester {
    address public owner;
    address public sp1Verifier;
    bytes32 public programVKey;

    uint256 public currentDynamicFee;
    uint256 public lastUpdateTimestamp;

    modifier onlyOwner() {
        require(msg.sender == owner, "SYSTEM HALTED: Unauthorized entity.");
        _;
    }

    // 物理實體化時，注入初始驗證器與程序印記
    constructor(address _sp1Verifier, bytes32 _programVKey) {
        owner = msg.sender;
        sp1Verifier = _sp1Verifier;
        programVKey = _programVKey;
        
        currentDynamicFee = 4300; // 初始霸權底線 43%
        lastUpdateTimestamp = block.timestamp;
    }

    // 預留後續對接真實 SP1 Verifier 的熱插拔插槽
    function setVerifier(address _newVerifier) external onlyOwner {
        sp1Verifier = _newVerifier;
    }

    // 接收 bytes proof 的物理接口
    function updateFeeWithZKProof(bytes calldata publicValues, bytes calldata proofBytes) external {
        // 1. 調用 SP1 雷達，驗證證明的合法性
        ISP1Verifier(sp1Verifier).verifyProof(programVKey, publicValues, proofBytes);

        // 2. 物理提取：解析 publicValues 獲取新稅率
        uint256 newFee = abi.decode(publicValues, (uint256));
        require(newFee <= 10000, "SYSTEM HALTED: Tax rate overflow.");
        
        currentDynamicFee = newFee;
        lastUpdateTimestamp = block.timestamp;
    }
}