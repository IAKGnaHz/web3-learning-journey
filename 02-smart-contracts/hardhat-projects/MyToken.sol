// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MyToken
 * @dev 实现ERC-20标准的代币合约
 * 学习重点：接口实现、代币经济、安全性考虑
 */

// ERC-20接口定义
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 扩展的元数据接口
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract MyToken is IERC20, IERC20Metadata {
    // 状态变量
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;
    
    // 额外功能的状态变量
    bool public paused;
    mapping(address => bool) public blacklisted;
    uint256 public maxTransferAmount;
    
    // 事件
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Paused();
    event Unpaused();
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    
    // 修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    modifier notBlacklisted(address _account) {
        require(!blacklisted[_account], "Account is blacklisted");
        _;
    }
    
    /**
     * @dev 构造函数
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 小数位数
     * @param _initialSupply 初始供应量
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        _totalSupply = _initialSupply * 10**uint256(_decimals);
        _balances[msg.sender] = _totalSupply;
        maxTransferAmount = _totalSupply / 100; // 默认最大转账金额为总供应量的1%
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    // ===== ERC-20 标准函数 =====
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) 
        public override whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    // ===== 内部函数 =====
    
    function _transfer(address sender, address recipient, uint256 amount) 
        internal notBlacklisted(sender) notBlacklisted(recipient) {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(_balances[sender] >= amount, "Insufficient balance");
        require(amount <= maxTransferAmount, "Transfer amount exceeds maximum");
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address _owner, address spender, uint256 amount) internal {
        require(_owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    
    // ===== 扩展功能 =====
    
    /**
     * @dev 铸造新代币
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Mint to zero address");
        
        _totalSupply += amount;
        _balances[to] += amount;
        
        emit Transfer(address(0), to, amount);
        emit Mint(to, amount);
    }
    
    /**
     * @dev 销毁代币
     */
    function burn(uint256 amount) public {
        require(_balances[msg.sender] >= amount, "Burn amount exceeds balance");
        
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }
    
    /**
     * @dev 暂停合约
     */
    function pause() public onlyOwner {
        paused = true;
        emit Paused();
    }
    
    /**
     * @dev 恢复合约
     */
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused();
    }
    
    /**
     * @dev 添加黑名单
     */
    function addToBlacklist(address account) public onlyOwner {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }
    
    /**
     * @dev 移除黑名单
     */
    function removeFromBlacklist(address account) public onlyOwner {
        blacklisted[account] = false;
        emit Unblacklisted(account);
    }
    
    /**
     * @dev 设置最大转账金额
     */
    function setMaxTransferAmount(uint256 _maxAmount) public onlyOwner {
        require(_maxAmount > 0, "Max transfer amount must be greater than 0");
        maxTransferAmount = _maxAmount;
    }
    
    /**
     * @dev 转移所有权
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        owner = newOwner;
    }
    
    /**
     * @dev 批量转账
     */
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) 
        public whenNotPaused returns (bool) {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        
        return true;
    }
    
    /**
     * @dev 增加授权额度
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    /**
     * @dev 减少授权额度
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}
