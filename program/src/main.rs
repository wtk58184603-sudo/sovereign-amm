//! Tower System 真實大腦：LVR 防禦矩陣
#![no_main]
sp1_zkvm::entrypoint!(main);

pub fn main() {
    // 1. 讀取發射器傳來的物理市場參數
    let amm_price = sp1_zkvm::io::read::<u64>();
    let oracle_price = sp1_zkvm::io::read::<u64>();
    let base_fee = sp1_zkvm::io::read::<u64>();

    // 2. 核心邏輯：計算絕對差值
    let diff = if oracle_price > amm_price {
        oracle_price - amm_price
    } else {
        amm_price - oracle_price
    };

    // 3. 制定剝削費率：基礎費率 + 差價的萬分之一
    let dynamic_fee = base_fee + (diff / 10000);

    // 4. 將戰果原樣輸出，交給收割機
    sp1_zkvm::io::commit(&amm_price);
    sp1_zkvm::io::commit(&oracle_price);
    sp1_zkvm::io::commit(&dynamic_fee);
}