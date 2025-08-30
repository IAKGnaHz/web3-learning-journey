// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VotingSystem
 * @dev 简单的投票系统 - 学习更复杂的数据结构和逻辑
 */
contract VotingSystem {
    // 提案结构
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 createdAt;
        uint256 deadline;
        address proposer;
        bool executed;
    }
    
    // 投票者结构
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
        uint256 weight;  // 投票权重
    }
    
    // 状态变量
    address public chairperson;
    uint256 public proposalCounter;
    uint256 public totalVoters;
    
    // 映射
    mapping(uint256 => Proposal) public proposals;
    mapping(address => Voter) public voters;
    mapping(uint256 => mapping(address => bool)) public hasVotedForProposal;
    
    // 数组
    uint256[] public activeProposalIds;
    
    // 事件
    event VoterRegistered(address indexed voter, uint256 weight);
    event ProposalCreated(uint256 indexed proposalId, string description, address proposer);
    event VoteCast(address indexed voter, uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId);
    
    // 修饰器
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call");
        _;
    }
    
    modifier onlyRegistered() {
        require(voters[msg.sender].isRegistered, "Not registered to vote");
        _;
    }
    
    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCounter, "Proposal does not exist");
        _;
    }
    
    // 构造函数
    constructor() {
        chairperson = msg.sender;
        // 主席自动注册为投票者，权重为2
        voters[chairperson] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0,
            weight: 2
        });
        totalVoters = 1;
    }
    
    // 注册投票者
    function registerVoter(address _voter, uint256 _weight) public onlyChairperson {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_weight > 0, "Weight must be greater than 0");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0,
            weight: _weight
        });
        
        totalVoters++;
        emit VoterRegistered(_voter, _weight);
    }
    
    // 批量注册投票者
    function registerVoters(address[] memory _voters, uint256 _weight) public onlyChairperson {
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!voters[_voters[i]].isRegistered) {
                registerVoter(_voters[i], _weight);
            }
        }
    }
    
    // 创建提案
    function createProposal(string memory _description, uint256 _durationInDays) public onlyRegistered {
        proposalCounter++;
        
        proposals[proposalCounter] = Proposal({
            id: proposalCounter,
            description: _description,
            voteCount: 0,
            createdAt: block.timestamp,
            deadline: block.timestamp + (_durationInDays * 1 days),
            proposer: msg.sender,
            executed: false
        });
        
        activeProposalIds.push(proposalCounter);
        emit ProposalCreated(proposalCounter, _description, msg.sender);
    }
    
    // 投票
    function vote(uint256 _proposalId) public onlyRegistered proposalExists(_proposalId) {
        Voter storage voter = voters[msg.sender];
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!hasVotedForProposal[_proposalId][msg.sender], "Already voted for this proposal");
        require(!proposal.executed, "Proposal already executed");
        
        // 记录投票
        proposal.voteCount += voter.weight;
        hasVotedForProposal[_proposalId][msg.sender] = true;
        
        // 更新投票者状态（仅记录最近一次投票）
        voter.hasVoted = true;
        voter.votedProposalId = _proposalId;
        
        emit VoteCast(msg.sender, _proposalId);
    }
    
    // 获取获胜提案
    function getWinningProposal() public view returns (uint256 winningProposalId) {
        uint256 winningVoteCount = 0;
        
        for (uint256 i = 0; i < activeProposalIds.length; i++) {
            uint256 proposalId = activeProposalIds[i];
            if (proposals[proposalId].voteCount > winningVoteCount && 
                !proposals[proposalId].executed) {
                winningVoteCount = proposals[proposalId].voteCount;
                winningProposalId = proposalId;
            }
        }
        
        require(winningProposalId != 0, "No proposals available");
        return winningProposalId;
    }
    
    // 执行提案
    function executeProposal(uint256 _proposalId) public onlyChairperson proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount > 0, "No votes cast");
        
        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }
    
    // 获取提案详情
    function getProposal(uint256 _proposalId) public view proposalExists(_proposalId) 
        returns (string memory description, uint256 voteCount, uint256 deadline, address proposer, bool executed) {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.voteCount,
            proposal.deadline,
            proposal.proposer,
            proposal.executed
        );
    }
    
    // 获取活跃提案数量
    function getActiveProposalCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < activeProposalIds.length; i++) {
            if (!proposals[activeProposalIds[i]].executed && 
                block.timestamp < proposals[activeProposalIds[i]].deadline) {
                count++;
            }
        }
        return count;
    }
    
    // 检查是否可以投票
    function canVote(address _voter, uint256 _proposalId) public view returns (bool) {
        if (!voters[_voter].isRegistered) return false;
        if (!(_proposalId > 0 && _proposalId <= proposalCounter)) return false;
        if (hasVotedForProposal[_proposalId][_voter]) return false;
        if (proposals[_proposalId].executed) return false;
        if (block.timestamp >= proposals[_proposalId].deadline) return false;
        return true;
    }
}
