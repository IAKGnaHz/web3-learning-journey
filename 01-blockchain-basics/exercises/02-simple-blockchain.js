/**
 * 练习2：构建简单的区块链
 * 目标：理解区块链的基本结构和工作原理
 */

const crypto = require('crypto');

// 区块类
class Block {
    constructor(index, timestamp, data, previousHash = '') {
        this.index = index;                // 区块序号
        this.timestamp = timestamp;        // 时间戳
        this.data = data;                  // 区块数据
        this.previousHash = previousHash;  // 前一个区块的哈希
        this.nonce = 0;                    // 工作量证明随机数
        this.hash = this.calculateHash();  // 当前区块的哈希
    }
    
    // 计算区块哈希
    calculateHash() {
        return crypto
            .createHash('sha256')
            .update(
                this.index + 
                this.timestamp + 
                JSON.stringify(this.data) + 
                this.previousHash + 
                this.nonce
            )
            .digest('hex');
    }
    
    // 挖矿（工作量证明）
    mineBlock(difficulty) {
        const target = '0'.repeat(difficulty);
        const startTime = Date.now();
        
        while (!this.hash.startsWith(target)) {
            this.nonce++;
            this.hash = this.calculateHash();
        }
        
        const endTime = Date.now();
        console.log(`区块 ${this.index} 挖矿成功！用时：${endTime - startTime}ms，Nonce：${this.nonce}`);
    }
}

// 区块链类
class Blockchain {
    constructor() {
        this.chain = [this.createGenesisBlock()];
        this.difficulty = 2; // 挖矿难度
    }
    
    // 创建创世区块
    createGenesisBlock() {
        return new Block(0, Date.now(), { message: "Genesis Block" }, "0");
    }
    
    // 获取最新区块
    getLatestBlock() {
        return this.chain[this.chain.length - 1];
    }
    
    // 添加新区块
    addBlock(newBlock) {
        // 设置新区块的前一个哈希
        newBlock.previousHash = this.getLatestBlock().hash;
        // 挖矿
        newBlock.mineBlock(this.difficulty);
        // 添加到链上
        this.chain.push(newBlock);
    }
    
    // 验证区块链是否有效
    isChainValid() {
        for (let i = 1; i < this.chain.length; i++) {
            const currentBlock = this.chain[i];
            const previousBlock = this.chain[i - 1];
            
            // 检查当前区块的哈希是否正确
            if (currentBlock.hash !== currentBlock.calculateHash()) {
                console.log(`❌ 区块 ${i} 的哈希不匹配`);
                return false;
            }
            
            // 检查是否指向正确的前一个区块
            if (currentBlock.previousHash !== previousBlock.hash) {
                console.log(`❌ 区块 ${i} 的前向链接断裂`);
                return false;
            }
            
            // 检查是否满足挖矿难度
            if (!currentBlock.hash.startsWith('0'.repeat(this.difficulty))) {
                console.log(`❌ 区块 ${i} 不满足挖矿难度要求`);
                return false;
            }
        }
        return true;
    }
    
    // 打印区块链
    printChain() {
        console.log('\n=== 区块链内容 ===');
        this.chain.forEach(block => {
            console.log(`\n区块 #${block.index}`);
            console.log(`  时间戳: ${new Date(block.timestamp).toLocaleString()}`);
            console.log(`  数据: ${JSON.stringify(block.data)}`);
            console.log(`  前哈希: ${block.previousHash.substring(0, 20)}...`);
            console.log(`  哈希值: ${block.hash.substring(0, 20)}...`);
            console.log(`  Nonce: ${block.nonce}`);
        });
    }
}

// ============ 使用示例 ============

console.log('🚀 创建新的区块链...\n');
const myBlockchain = new Blockchain();

console.log('⛏️  开始添加区块...\n');

// 添加第一个区块
myBlockchain.addBlock(new Block(
    1,
    Date.now(),
    { 
        sender: 'Alice',
        receiver: 'Bob',
        amount: 100
    }
));

// 添加第二个区块
myBlockchain.addBlock(new Block(
    2,
    Date.now(),
    { 
        sender: 'Bob',
        receiver: 'Charlie',
        amount: 50
    }
));

// 添加第三个区块
myBlockchain.addBlock(new Block(
    3,
    Date.now(),
    { 
        sender: 'Charlie',
        receiver: 'Alice',
        amount: 25
    }
));

// 打印区块链
myBlockchain.printChain();

// 验证区块链
console.log('\n🔍 验证区块链完整性...');
console.log(`区块链是否有效: ${myBlockchain.isChainValid() ? '✅ 是' : '❌ 否'}`);

// 演示篡改检测
console.log('\n⚠️  尝试篡改区块2的数据...');
myBlockchain.chain[2].data = { 
    sender: 'Bob',
    receiver: 'Charlie',
    amount: 5000  // 篡改金额
};
myBlockchain.chain[2].hash = myBlockchain.chain[2].calculateHash();
console.log(`区块链是否有效: ${myBlockchain.isChainValid() ? '✅ 是' : '❌ 否'}`);

// 练习任务
console.log('\n📝 扩展练习：');
console.log('1. 添加一个方法计算某个地址的余额');
console.log('2. 实现交易签名验证');
console.log('3. 添加交易池和待确认交易');
console.log('4. 实现动态调整挖矿难度');
