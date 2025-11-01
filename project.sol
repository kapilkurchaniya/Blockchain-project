// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StudentUnionDAO – College Governance with DAO
 * @dev A decentralized governance platform for student decision-making.
 * Students can submit proposals, vote, and view results transparently.
 */
contract StudentUnionDAO {
    struct Proposal {
        uint id;
        string title;
        string description;
        uint voteCount;
        uint againstCount;
        uint deadline;
        bool executed;
        address proposer;
    }

    uint public proposalCount;
    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    address public admin;
    uint public votingPeriod = 3 days;

    event ProposalCreated(uint id, string title, address proposer);
    event VoteCast(uint proposalId, address voter, bool support);
    event ProposalExecuted(uint proposalId, bool passed);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier proposalExists(uint _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Proposal does not exist");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev Create a new governance proposal.
     * @param _title Title of the proposal.
     * @param _description Description of the proposal.
     */
    function createProposal(string memory _title, string memory _description) external {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            title: _title,
            description: _description,
            voteCount: 0,
            againstCount: 0,
            deadline: block.timestamp + votingPeriod,
            executed: false,
            proposer: msg.sender
        });

        emit ProposalCreated(proposalCount, _title, msg.sender);
    }

    /**
     * @dev Cast a vote on an active proposal.
     * @param _proposalId ID of the proposal.
     * @param _support True for yes, false for no.
     */
    function vote(uint _proposalId, bool _support) external proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.deadline, "Voting period has ended");
        require(!hasVoted[_proposalId][msg.sender], "You have already voted");

        hasVoted[_proposalId][msg.sender] = true;

        if (_support) {
            proposal.voteCount++;
        } else {
            proposal.againstCount++;
        }

        emit VoteCast(_proposalId, msg.sender, _support);
    }

    /**
     * @dev Execute proposal after voting period ends.
     * Marks proposal as executed and emits results.
     */
    function executeProposal(uint _proposalId) external proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        bool passed = proposal.voteCount > proposal.againstCount;

        emit ProposalExecuted(_proposalId, passed);
    }

    /**
     * @dev Update voting period (admin only).
     */
    function updateVotingPeriod(uint _newPeriod) external onlyAdmin {
        votingPeriod = _newPeriod;
    }
}
