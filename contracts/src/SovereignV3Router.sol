// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Harvester} from "./Harvester.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract SovereignV3Router {
    address public immutable TREASURY; 
    Harvester public harvester;
    address public uniswapV3Pool;

    constructor(address _harvester, address _pool, address _treasury) {
        harvester = Harvester(_harvester);
        uniswapV3Pool = _pool;
        TREASURY = _treasury;
    }

    /**
     * @notice 分润型拦截逻辑：[43/10/47] 物理分账
     * 100% Input -> 43% Treasury + 10% Prover (msg.sender) + 47% Pool
     */
    function exactInputSingle(
        address tokenIn,
        address /* tokenOut */, 
        uint256 amountIn,
        uint256 /* amountOutMinimum */ 
    ) external returns (uint256 amountOut) {
        
       // 1. 获取 ZK 大脑裁决结果
        uint256 currentZkTaxRate = harvester.currentDynamicFee();
        require(block.timestamp - harvester.lastUpdateTimestamp() <= 60, "SYSTEM HALTED: ZK Fee is outdated.");

        // 2. 物理分账参数校准 (以 10000 为基数)
        // 强制变量注入：彻底废弃 43% 死数字，使用 ZK 实时计算出的动态税率
        uint256 treasuryShare = (amountIn * currentZkTaxRate) / 10000; 
        uint256 proverReward = (amountIn * 1000) / 10000;  // 10% 算力悬赏不变
        uint256 poolAmount = amountIn - treasuryShare - proverReward; // 剩余兜底注入池

        // 3. 物理拉取：全额捕获用户资产
        bool successIn = IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        require(successIn, "SYSTEM HALTED: Input transfer failed!");

        // 4. 三路物理分发：即刻清算，不留风险敞口
        
        // 分发 A：主权抽成打入国库
        bool successTreasury = IERC20(tokenIn).transfer(TREASURY, treasuryShare);
        require(successTreasury, "SYSTEM HALTED: Treasury distribution failed!");

        // 分发 B：算力悬赏打给 Prover (当前调用者)
        bool successProver = IERC20(tokenIn).transfer(msg.sender, proverReward);
        require(successProver, "SYSTEM HALTED: Prover bounty failed!");

        // 分发 C：流动性补偿注入池子
        bool successPool = IERC20(tokenIn).transfer(uniswapV3Pool, poolAmount);
        require(successPool, "SYSTEM HALTED: Pool compensation failed!");

        return poolAmount; 
    }
}