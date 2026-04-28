#![no_main]
sp1_zkvm::entrypoint!(main);

pub fn main() {
    // 1. 動態參數注入：不僅讀取價格，還讀取「塔台」下發的動態閾值
    let pre_price = sp1_zkvm::io::read::<u32>();
    let post_price = sp1_zkvm::io::read::<u32>();
    
    // 主權意志解耦：閾值由外部傳入，不再硬編碼死數字
    let volatility_threshold = sp1_zkvm::io::read::<u32>(); // 控制台傳入的波動閾值 (如 100 = 1%)
    let predator_tax_rate = sp1_zkvm::io::read::<u32>();    // 掠奪稅率 (如 8000 = 80%)
    let baseline_tax_rate = sp1_zkvm::io::read::<u32>();    // 生存基線稅率 (如 4300 = 43%)

    // 2. 計算波動率基點 (放大 10000 倍以執行純整數運算)
    let diff = if post_price > pre_price { post_price - pre_price } else { pre_price - post_price };
    let volatility_bps = (diff * 10000) / pre_price;

    // 3. 裁決引擎 (根據外部動態閾值進行非線性定價)
    let target_tax_rate: u32 = if volatility_bps > volatility_threshold {
        predator_tax_rate 
    } else {
        baseline_tax_rate 
    };

    // 4. 字節碼封裝 (極致壓縮，對齊以太坊標準)
    let mut abi_encoded_fee = [0u8; 32];
    abi_encoded_fee[28..32].copy_from_slice(&target_tax_rate.to_be_bytes());
    sp1_zkvm::io::commit_slice(&abi_encoded_fee);
}