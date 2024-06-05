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
    uint public bookCount = 0;
    
    mapping(uint => VotingSession) votingSessions;
    uint public votingSessionCount = 0;

    // creates a new book
    function createBook(string memory _title) public returns (Book memory) {
        Book memory book = Book(
            bookCount,
            _title
        );
        books[bookCount] = book;
        bookCount++;
        return book;
    }

    // creates new voting session for a book 
    function createVotingSession(uint _bookId) public returns (VotingSession memory) {
        Book storage book = books[_bookId];
        VotingSession memory votingSession = VotingSession(
            votingSessionCount,
            book 
        );
        votingSessions[votingSessionCount] = votingSession;
        votingSessionCount++;
        return votingSession;
    }
}
