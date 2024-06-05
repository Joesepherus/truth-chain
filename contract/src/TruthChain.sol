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

    // voting_session_id => address => vote
    mapping(uint => mapping(address => Vote)) public votes;
    // voting_session_id => array of address 
    mapping(uint => address[]) public voterAddresses;

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

   function voteOnBook(uint _sessionId, bool decision) public {
       Vote memory foundVote = getVoteForSessionAndVoter(_sessionId, msg.sender);
       require(foundVote.voter == address(0), "You can only vote once per voting session!");
       Vote memory vote = Vote(decision, msg.sender);
       votes[_sessionId][msg.sender] = vote;
       voterAddresses[_sessionId].push(msg.sender);
   }

   function getAddressesVotedForSession(uint _sessionId) public view returns (address[] memory) {
       address[] memory _voterAddresses = voterAddresses[_sessionId];
       return _voterAddresses;
   }

   function getVotesForSession(uint _sessionId) public view returns (Vote[] memory) {
       address[] memory _voterAddresses = voterAddresses[_sessionId];

       Vote[] memory votesForSession = new Vote[](_voterAddresses.length); 
       uint j = 0;
       for (uint i = 0; i < _voterAddresses.length; i++) {
           Vote memory foundVote = getVoteForSessionAndVoter(_sessionId, _voterAddresses[i]);
           if(foundVote.voter != address(0)){
               votesForSession[j] = foundVote;
               j++;
           }

       }
       return votesForSession;
   }

   function getVoteForSessionAndVoter(uint _sessionId, address _voterAddress) public view returns (Vote memory) {
       return votes[_sessionId][_voterAddress];
   }

}
