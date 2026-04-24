// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Harvester} from "../src/Harvester.sol";
import {SovereignV3Router} from "../src/SovereignV3Router.sol";

// 物理環境模擬：Mock Token
contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }
    function approve(address spender, uint256 amount) external returns (bool) { allowance[msg.sender][spender] = amount; return true; }
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "ERC20: balance too low");
        balanceOf[msg.sender] -= amount; balanceOf[recipient] += amount; return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "ERC20: balance too low");
        require(allowance[sender][msg.sender] >= amount, "ERC20: allowance too low");
        balanceOf[sender] -= amount; allowance[sender][msg.sender] -= amount; balanceOf[recipient] += amount; return true;
    }
}

// ---------------------------------------------------------
// 這裡就是你丟失的「合約外殼」與基礎變數
// ---------------------------------------------------------
contract SovereignV3RouterTest is Test {
    Harvester public harvester;
    SovereignV3Router public router;
    MockERC20 public token;

    address public TREASURY = address(0x999);
    address public MOCK_POOL = address(0x888);
    address public HACKER = address(0x666); // 在測試中，黑客同時扮演了觸發交易的 Prover 角色

    function setUp() public {
        harvester = new Harvester();
        router = new SovereignV3Router(address(harvester), MOCK_POOL, TREASURY);
        token = new MockERC20();
        // 發放 100 枚測試 ETH 給黑客
        token.mint(HACKER, 100 ether); 
    }

    // ---------------------------------------------------------
    // 分潤法則測試核心
    // ---------------------------------------------------------
    function testAtomicRobbery() public {
        uint256 proofTime = 1776782409; 
        vm.warp(proofTime + 5); 

        // 模擬 ZK 大腦產出 5300 (53%) 的費率
        bytes memory publicValues = hex"005ed0b200000000804ecbb500000000b414000000000000";
        bytes memory mockProof = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        harvester.executeHarvest(publicValues, mockProof, proofTime);

        // 虛構黑客 (Prover) 發起 100 ETH 的套利攻擊
        vm.startPrank(HACKER); 
        token.approve(address(router), 100 ether);
        // Router 會強行拿走這 100 ETH，並立刻執行 43/10/47 分發
        router.exactInputSingle(address(token), address(0), 100 ether, 0);
        vm.stopPrank();

        // ==========================================
        // 戰果物理清算 (以戰養戰驗證)
        // ==========================================
        uint256 treasuryBalance = token.balanceOf(TREASURY);
        uint256 proverBalance = token.balanceOf(HACKER); // msg.sender 是 HACKER
        uint256 poolBalance = token.balanceOf(MOCK_POOL);

        console.log(unicode"\n=== Phase 2 分潤法則清算報告 ===");
        console.log(unicode"國庫主權抽成 (ETH):", treasuryBalance / 1 ether);
        console.log(unicode"算力懸賞分紅 (ETH):", proverBalance / 1 ether);
        console.log(unicode"流動性池注入 (ETH):", poolBalance / 1 ether);
        console.log(unicode"=================================\n");

        // 物理斷言：
        // 1. 國庫是否拿到 43%?
        assertEq(treasuryBalance, 43 ether, "CRITICAL: Treasury share mismatch!");
        
        // 2. Prover (HACKER) 是否拿到 10% 懸賞? 
        // 解析：HACKER 初始 100，花了 100 變 0，然後 Router 懸賞給它 10，所以最後是 10
        assertEq(proverBalance, 10 ether, "CRITICAL: Prover bounty mismatch!");
        
        // 3. 池子是否拿到 47% 補償?
        assertEq(poolBalance, 47 ether, "CRITICAL: Pool balance mismatch!");
    }
}