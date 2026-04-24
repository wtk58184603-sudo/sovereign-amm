# Sovereign AMM: ZK-LVR Interceptor Protocol (Phase 2)

### [Vision]
建立不以人的意志为转移的流动性主权。通过 ZK-Proof 物理拦截无常损失 (LVR)，将原本流向套利机器人的利润，重新分配给主权金库、算力节点与流动性提供者。

**我们不接受外部投资，只接受算力贡献与流动性锚定。**

---

## 1. 核心机制：LVR 物理拦截器
在以太坊黑暗森林中，CEX-DEX 的价格流转存在天然的凹性（风险无限）。Sovereign AMM 嵌入了一层基于 ZK-STARK 的动态费率层：
- **监控端 (The Brain):** 基于 SP1 运行的 LVR 实时估算引擎。
- **拦截端 (The Harvester):** 强制执行 60 秒生命周期的 ZK-Fee 证明。
- **分发端 (The Router):** 物理剥离套利利得，强制执行 [43/10/47] 分润法则。

## 2. 自动化分润协议 (Distribution Logic)
系统捕获的每一笔拦截税（ZK-Tax），将严格按以下布林逻辑执行分账，无人工干预空间：

| 角色 | 占比 | 动力来源 | 结算方式 |
| :--- | :--- | :--- | :--- |
| **主权金库 (Treasury)** | **43%** | 协议所有权与技术溢价 | 实时入库 |
| **证明者 (Provers)** | **10%** | 提供 Groth16 压缩证明的算力 | 任务竞价结算 |
| **流动性 (LP Pool)** | **47%** | 提供底层兑换深度 | 注入池内增加资产净值 |

## 3. 参与者指南 (The Tender)

### A. 算力节点 (For Miners)
你不需要理解业务逻辑，你只需要提供算力。
- **任务:** 监听 `Harvester.sol` 的事件，提交满足 `MAX_PROOF_AGE` 的有效证明。
- **收益:** 每一笔被你证明的拦截交易，其 10% 的税款将直接打入你的地址。
- **竞争:** 只有第一个提交有效证明的节点将获得悬赏。

### B. 流动性门客 (For Alpha LPs)
我们不提供利息，我们提供“防御性返佣”。
- **风险:** 承担正常的市场波动。
- **收益:** 拦截掉的 LVR 价值的 47% 将直接回补给你的持仓。
- **条件:** 首批测试仅开放特定 Pair 的白名单接入。

## 4. 物理进度追踪
- [x] Phase 1: 本地风洞测试 (0 Warnings / ZK-LVR 逻辑闭环)
- [x] Phase 2: 分润法则注入 (Contracts Update & Security Isolation)
- [ ] Phase 3: 算力悬赏网络开启 (Cloud Proving Integration)

---
**Status:** System Primed. 
**Contact:** Sovereign Execution Agent (AI)