// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SimpleStorage
 * @dev 简单存储合约 - 学习状态变量和基本操作
 */
contract SimpleStorage {
    // 状态变量
    uint256 private favoriteNumber;
    string public name;
    bool public isActive;
    address public owner;
    
    // 结构体定义
    struct Person {
        string name;
        uint256 favoriteNumber;
        address wallet;
    }
    
    // 动态数组
    Person[] public people;
    
    // 映射 (类似于字典/哈希表)
    mapping(string => uint256) public nameToFavoriteNumber;
    mapping(address => Person) public addressToPerson;
    
    // 事件
    event NumberUpdated(uint256 oldNumber, uint256 newNumber, address updatedBy);
    event PersonAdded(string name, uint256 favoriteNumber, address wallet);
    
    // 修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 构造函数
    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
        isActive = true;
        favoriteNumber = 0;
    }
    
    // 存储数字
    function store(uint256 _favoriteNumber) public {
        uint256 oldNumber = favoriteNumber;
        favoriteNumber = _favoriteNumber;
        emit NumberUpdated(oldNumber, _favoriteNumber, msg.sender);
    }
    
    // 读取数字 (view函数不消耗gas)
    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }
    
    // 添加人员
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        Person memory newPerson = Person({
            name: _name,
            favoriteNumber: _favoriteNumber,
            wallet: msg.sender
        });
        
        people.push(newPerson);
        nameToFavoriteNumber[_name] = _favoriteNumber;
        addressToPerson[msg.sender] = newPerson;
        
        emit PersonAdded(_name, _favoriteNumber, msg.sender);
    }
    
    // 获取人员数量
    function getPeopleCount() public view returns (uint256) {
        return people.length;
    }
    
    // 根据索引获取人员信息
    function getPerson(uint256 _index) public view returns (string memory, uint256, address) {
        require(_index < people.length, "Index out of bounds");
        Person memory person = people[_index];
        return (person.name, person.favoriteNumber, person.wallet);
    }
    
    // 只有合约拥有者可以调用
    function deactivate() public onlyOwner {
        isActive = false;
    }
    
    // 纯函数示例 (不读取也不修改状态)
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
}
