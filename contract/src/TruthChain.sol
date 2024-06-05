// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

contract TruthChain {
    struct Book {
        uint id;
        string title;
    }

    struct VotingSession {
        uint id;
        Book book;
    }

    // voting_session_id => book_id => address => boolean
    mapping(uint => mapping(uint => mapping(address => bool))) votes;
    mapping(uint => Book) books;
    uint bookCount = 1;
    
    mapping(uint => VotingSession) votingSessions;
    uint public votingSessionCount;

    // creates a new book
    function createBook(string _title) private {
        Book memory book = Book(
            bookCount,
            _title
        );
        books[bookCount] = book;
        bookCount++;
    }

    // creates new voting session for a book 
    function createVotingSession(uint _id, uint _bookId) private {
        Book storage book = books[_bookId];
        VotingSession memory votingSession = VotingSession(
            _id,
            book 
        );
        votingSessions[votingSessionCount] = votingSession;
    }
}
