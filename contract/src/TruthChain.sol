// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TruthChain {
    uint256 public votingSessionNmber;
    struct Book {
        uint id;
        string title;
    }
    
    // voting_session_id => book_id => address => boolean
    mapping(uint => mapping(uint => mapping(address => bool))) votes; 
}
