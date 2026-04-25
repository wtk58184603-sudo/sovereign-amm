//! Tower System 發射器：LVR 證明鍛造與 ABI 序列化
use sp1_sdk::{
    blocking::{ProverClient, Prover, ProveRequest},
    include_elf, utils, SP1Stdin,
};
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    utils::setup_logger();

    let client = ProverClient::from_env();
    let elf = include_elf!("sovereign-program");

    let mut stdin = SP1Stdin::new();
    let amm_price: u64 = 3000_000_000;
    let oracle_price: u64 = 3050_000_000;
    let base_fee: u64 = 300;

    stdin.write(&amm_price);
    stdin.write(&oracle_price);
    stdin.write(&base_fee);

    println!("Tower System 啟動：開始鍛造證明...");
    let pk = client.setup(elf).expect("Setup 失敗！");
    let proof = client.prove(&pk, stdin).run().expect("證明鍛造失敗！");

    // =====================================================================
    // ABI 序列化與時間戳提取
    // =====================================================================
    let public_values_bytes = proof.public_values.as_slice();
    let mock_proof_bytes = vec![0xff; 32]; 

    // 提取物理時間戳，為 Solidity 的 60 秒生命週期計時器提供起點
    let current_timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    println!("\n=== Tower System 鏈上裝填彈藥 ===");
    println!("請將以下參數直接複製到 Solidity 靶場中：");
    println!("Public Values: 0x{}", hex::encode(public_values_bytes));
    println!("Mock Proof:    0x{}", hex::encode(&mock_proof_bytes));
    println!("Timestamp:     {}", current_timestamp);
    println!("=================================");
}