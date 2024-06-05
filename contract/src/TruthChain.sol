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

    struct Vote {
        bool decision;
        address voter;
    }

    // voting_session_id   => address => boolean
//    mapping(uint => mapping(address => bool)) votes;
    // voting_session_id => vote
    mapping(uint => Vote[]) public votes;

    // books
    mapping(uint => Book) books;
    uint public bookCount = 0;
    
    // voting sessions
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

   function voteOnBook(uint _votingSessionId, bool decision) public {
       Vote memory vote = Vote(decision, msg.sender);
       votes[_votingSessionId].push(vote);
   }
    
   function getVotesForSession(uint _sessionId) public returns (Vote[] memory) {
       return votes[_sessionId];
   }

}
