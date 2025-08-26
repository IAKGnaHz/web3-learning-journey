// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title HelloWorld
 * @dev 我的第一个智能合约
 * @notice 这是一个简单的问候合约，用于学习Solidity基础
 */
contract HelloWorld {
    // 状态变量：存储问候消息
    string public greeting;
    
    // 事件：记录问候消息的更改
    event GreetingChanged(string oldGreeting, string newGreeting, address changer);
    
    /**
     * @dev 构造函数，部署时设置初始问候语
     * @param _greeting 初始的问候消息
     */
    constructor(string memory _greeting) {
        greeting = _greeting;
    }
    
    /**
     * @dev 获取当前的问候消息
     * @return 当前存储的问候语
     */
    function getGreeting() public view returns (string memory) {
        return greeting;
    }
    
    /**
     * @dev 设置新的问候消息
     * @param _newGreeting 新的问候语
     */
    function setGreeting(string memory _newGreeting) public {
        string memory oldGreeting = greeting;
        greeting = _newGreeting;
        
        // 触发事件
        emit GreetingChanged(oldGreeting, _newGreeting, msg.sender);
    }
    
    /**
     * @dev 获取合约部署者的地址示例
     * @return 调用者的地址
     */
    function getCaller() public view returns (address) {
        return msg.sender;
    }
}
