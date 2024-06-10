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
        uint stakedPool;
        bool active;
        bool distributed;
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
    mapping(uint => VotingSession) public votingSessions;
    uint public votingSessionCount = 0;

    uint256 public totalBalance;
    mapping(address => uint256) public balances;

    address public owner;

    mapping(address => uint256) public lockedBalances;

    uint constant LOCK_NEEDED = 5000000000000000000;

    uint constant REWARD_FROM_STASH_PERCENTAGE = 10;

    address constant OWNER_ADDRESS = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    uint256 constant SCALE = 1e18;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You need to be an owner for this operation.");        
        _;
    }

    function deposit() external payable {
        require(msg.value != 0, "Invalid deposit.");

        // Increment record
        totalBalance += msg.value;
        balances[msg.sender] += msg.value;
    }

    // creates a new book
    function createBook(string memory _title) public onlyOwner returns (Book memory) {
        Book memory book = Book(
            bookCount,
            _title
        );
        books[bookCount] = book;
        bookCount++;
        return book;
    }

    // creates new voting session for a book 
    function createVotingSession(uint _bookId) public onlyOwner returns (VotingSession memory) {
        Book storage book = books[_bookId];
        VotingSession memory votingSession = VotingSession(
            votingSessionCount,
            book,
            0,
            true,
            false
        );
        votingSessions[votingSessionCount] = votingSession;
        votingSessionCount++;
        return votingSession;
    }

   function voteOnBook(uint _sessionId, bool decision) public payable {
       require(lockedBalances[msg.sender] == LOCK_NEEDED, "You need to lock your coins first before voting.");
       Vote memory foundVote = getVoteForSessionAndVoter(_sessionId, msg.sender);
       require(foundVote.voter == address(0), "You can only vote once per voting session!");
       require(balances[msg.sender] >= 1 ether, "You need to stake 1 ether to vote.");
       VotingSession memory votingSession = votingSessions[_sessionId];
       require(votingSession.active == true, "Voting session is closed.");
       Vote memory vote = Vote(decision, msg.sender);
       votes[_sessionId][msg.sender] = vote;
       voterAddresses[_sessionId].push(msg.sender);
       votingSessions[_sessionId].stakedPool += 1;
       balances[msg.sender] -= 1000000000000000000;
   }

   function getBalance(address _addr) public view returns (uint) {
       return balances[_addr];
   }

   function endVotingSession(uint _sessionId) public onlyOwner {
       votingSessions[_sessionId].active = false;
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

   function getVotingSessionById(uint _sessionId) public view returns (VotingSession memory){
        VotingSession memory votingSession = votingSessions[_sessionId];
        return votingSession;
   }

   function distributeCoins(uint _sessionId) public onlyOwner {
        VotingSession memory votingSession = votingSessions[_sessionId];
        require(votingSession.active == false , "Voting session is still active.");
        require(votingSession.distributed == false, "Rewards have already been distributed.");
        TruthChain.Vote[] memory _votes = getVotesForSession(_sessionId);
             
        uint _votesCount = _votes.length;

        uint yesVotes = 0;
        address[] memory yesAddresses = new address[](_votesCount); 

        for(uint i=0; i < _votesCount; i++) {
            if(_votes[i].decision == true) {
                yesVotes++;
                yesAddresses[i] = _votes[i].voter;
            }
        }

        if(yesVotes == 0) {
            yesVotes = 1;
        }

        uint reward = divide(_votesCount, yesVotes);
        uint rewardFromStash = multiply(reward, divide(REWARD_FROM_STASH_PERCENTAGE, 100));

        if(balances[OWNER_ADDRESS] >= rewardFromStash){
            totalBalance -= rewardFromStash;
            balances[OWNER_ADDRESS] -= rewardFromStash;
            reward += rewardFromStash;
        }

        for(uint i=0; i < yesVotes; i++) {
            balances[yesAddresses[i]] += reward;
        }
        votingSessions[_sessionId].distributed = true;
   }


     function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return (a * b) / SCALE;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Division by zero");
        return (a * SCALE) / b;
    }

    function lockCoins(uint amount) public {
        require(lockedBalances[msg.sender] < LOCK_NEEDED, "You already have locked coins.");
        require(balances[msg.sender] >= amount, "You need to deposit more coins.");
        require(amount == LOCK_NEEDED, "You need to lock 5 ether exactly.");
        lockedBalances[msg.sender] = amount;
        balances[msg.sender] -= amount;
    }
}
