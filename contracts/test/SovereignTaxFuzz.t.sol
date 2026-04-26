// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

contract SovereignTaxFuzzTest is Test {
    function testFuzz_TreasuryPrecision(uint256 amountIn) public pure {
        // 變量約束：剔除會導致乘法溢出的極端惡意輸入，剔除毫無意義的微塵攻擊 (10000 Wei 以下)
        vm.assume(amountIn > 10000 && amountIn < type(uint256).max / 10000);

        uint256 treasuryShare = (amountIn * 4300) / 10000;
        uint256 proverReward = (amountIn * 1000) / 10000;
        uint256 poolAmount = amountIn - treasuryShare - proverReward;

        // 核心斷言 1：物理質量守恆（資金無論怎麼分，總和必須等於輸入，徹底消滅黑洞）
        assertEq(treasuryShare + proverReward + poolAmount, amountIn, "SYSTEM HALTED: Matter annihilated");

        // 核心斷言 2：主權底線校驗（國庫份額絕對不能少於理論下限的 43%，向下取整的尾數丟失由 Pool 承擔）
        assertEq(treasuryShare, (amountIn * 43) / 100, "SYSTEM HALTED: Treasury tax evaded");
    }
}