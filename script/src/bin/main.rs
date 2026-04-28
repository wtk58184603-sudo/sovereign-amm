use std::process::Command;
use std::str;
use alloy_primitives::U256;

fn main() {
    println!("=========================================");
    println!("SYSTEM OVERRIDE: Live Radar Engaged.");
    println!("Target: Chainlink ETH/USD Oracle (Sepolia)");
    println!("=========================================");

    println!("-> 正在掃描以太坊 Sepolia 區塊鏈...");
    let oracle_address = "0x694AA1769357215DE4FAC081bf1f309aDC325306";
    
    let output = Command::new("cast")
        // 【核心修正】：拔除 (int256)，強迫 cast 吐出最底層的十六進制原始碼
        .args(["call", oracle_address, "latestAnswer()", "--rpc-url"])
        .arg(std::env::var("SEPOLIA_RPC_URL").unwrap_or_else(|_| "https://rpc.sepolia.org".to_string()))
        .output()
        .expect("SYSTEM HALTED: 無法喚醒 cast 工具。");

    let result_raw = str::from_utf8(&output.stdout).unwrap().trim();
    
    // 開啟天眼：讓控制台印出到底抓到了什麼鬼東西
    println!("-> [雷達原始回傳]: {}", result_raw);

    if result_raw.is_empty() || !output.status.success() {
        let error_msg = str::from_utf8(&output.stderr).unwrap().trim();
        println!("-> [ERROR] 鏈上數據讀取失敗！原因: {}", error_msg);
        return;
    }

    // 剔除 0x，用 U256 強制按十六進制解析
    let clean_hex = result_raw.trim_start_matches("0x");
    let parsed_u256 = U256::from_str_radix(clean_hex, 16).unwrap_or(U256::ZERO);
    
    // Chainlink 縮放處理 (除以 10^6)
    let divisor = U256::from(1_000_000);
    let scaled_price_u256 = parsed_u256 / divisor;
    
    let live_price: u32 = scaled_price_u256.try_into().unwrap_or(0);

    if live_price == 0 {
        println!("-> [ERROR] 價格解析為 0，防禦機制啟動，拒絕開火！");
        return;
    }

    let pre_price: u32 = 300000; // 基準價 3000.00
    let post_price: u32 = live_price; 
    
    let volatility_threshold: u32 = 100; // 1%
    let predator_tax_rate: u32 = 8000;   // 80%
    let baseline_tax_rate: u32 = 4300;   // 43%

    println!("-> 基準 Pre-Price : {}", pre_price);
    println!("-> 鏈上即時 Post-Price: {}", post_price);

    let diff = if post_price > pre_price { post_price - pre_price } else { pre_price - post_price };
    let volatility_bps = (diff * 10000) / pre_price;
    
    println!("-> 實際計算波動率: {} bps", volatility_bps);

    let target_tax_rate = if volatility_bps > volatility_threshold {
        println!("-> [CRITICAL] 波動率越過邊界！啟動掠奪稅率：80%");
        predator_tax_rate
    } else {
        println!("-> [NORMAL] 波動率平穩，維持生存基線：43%");
        baseline_tax_rate
    };

    let mut abi_encoded_fee = vec![0u8; 32];
    abi_encoded_fee[28..32].copy_from_slice(&target_tax_rate.to_be_bytes());
    let public_values_hex = format!("0x{}", abi_encoded_fee.iter().map(|b| format!("{:02x}", b)).collect::<String>());
    let proof_hex = format!("0x{}", vec![0u8; 32].iter().map(|b| format!("{:02x}", b)).collect::<String>());
    
    println!("\n[ACTION REQUIRED] 大砲裝填完畢，開火指令如下：\n");
    println!(
        "cast send 0x91430ed99E2dE483B8a64a8D34441F03FC7a32a0 \"updateFeeWithZKProof(bytes,bytes)\" {} {} --rpc-url $SEPOLIA_RPC_URL --mnemonic \"$SEED_PHRASE\" --legacy",
        public_values_hex, proof_hex
    );
    println!("\n=========================================");
}