/**
 * 练习1：理解哈希函数
 * 目标：通过实践理解区块链中哈希函数的作用
 */

const crypto = require('crypto');

// 练习1.1：创建简单的哈希
function createHash(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

// 练习1.2：演示哈希的特性
console.log('=== 哈希函数特性演示 ===\n');

// 1. 相同输入产生相同输出
const input1 = 'Hello, Blockchain!';
console.log('输入1:', input1);
console.log('哈希1:', createHash(input1));
console.log('再次哈希相同输入:', createHash(input1));
console.log('✅ 特性1：确定性 - 相同输入总是产生相同输出\n');

// 2. 微小改变产生完全不同的哈希
const input2 = 'Hello, Blockchain.'; // 只改了一个符号
console.log('输入2 (细微改变):', input2);
console.log('哈希2:', createHash(input2));
console.log('✅ 特性2：雪崩效应 - 输入的微小改变导致输出完全不同\n');

// 3. 无法从哈希反推原始数据
const hash = createHash('secret message');
console.log('哈希值:', hash);
console.log('✅ 特性3：单向性 - 无法从哈希值反推原始信息\n');

// 练习1.3：模拟工作量证明（简化版）
function mineBlock(data, difficulty) {
    let nonce = 0;
    const target = '0'.repeat(difficulty);
    let hash = '';
    
    console.log(`开始挖矿，难度：${difficulty} (需要 ${difficulty} 个前导0)`);
    const startTime = Date.now();
    
    while (!hash.startsWith(target)) {
        nonce++;
        hash = createHash(data + nonce);
    }
    
    const endTime = Date.now();
    console.log(`✅ 挖矿成功！`);
    console.log(`   Nonce: ${nonce}`);
    console.log(`   Hash: ${hash}`);
    console.log(`   用时: ${endTime - startTime}ms`);
    console.log(`   尝试次数: ${nonce}`);
    
    return { nonce, hash };
}

// 尝试不同难度的挖矿
console.log('=== 工作量证明演示 ===\n');
mineBlock('Hello, Bitcoin!', 2);  // 2个前导0
console.log('');
mineBlock('Hello, Bitcoin!', 3);  // 3个前导0
console.log('');
// mineBlock('Hello, Bitcoin!', 4);  // 4个前导0 (可能需要较长时间)

// 练习任务：
console.log('\n📝 练习任务：');
console.log('1. 修改 mineBlock 函数，记录每1000次尝试');
console.log('2. 创建一个函数验证某个nonce是否有效');
console.log('3. 实现一个简单的区块结构，包含时间戳、数据和前一个区块的哈希');
