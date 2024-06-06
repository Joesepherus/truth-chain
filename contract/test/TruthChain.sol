pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TruthChain} from "../src/TruthChain.sol";

contract TruthChainTest is Test {
    TruthChain public truthChain;
    address constant voterAddress1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        truthChain = new TruthChain();
        vm.deal(voterAddress1, 100 ether);

        truthChain.createBook(
            "book 1"
        );

        truthChain.createVotingSession(0);
    }

    function test_CreateBook() public {
        TruthChain.Book memory book = truthChain.createBook(
            "book 2"
        );

        uint bookCount = truthChain.bookCount();
        assertEq(bookCount, 2);
        assertEq(book.id, 1);
        assertEq(book.title, "book 2");
   }

    function test_CreateVotingSession() public {
        TruthChain.VotingSession memory votingSession = truthChain.createVotingSession(0);
        
        uint votingSessionCount = truthChain.votingSessionCount();
        assertEq(votingSessionCount, 2);
        assertEq(votingSession.id, 1);
        assertEq(votingSession.active, true);
    }

    function test_VoteOnBook() public {
        vm.prank(voterAddress1);
        truthChain.voteOnBook{value: 1 ether}(0, true);

        address[] memory addresses = truthChain.getAddressesVotedForSession(0);
        assertEq(addresses.length, 1);

        TruthChain.Vote[] memory votes = truthChain.getVotesForSession(0);
        uint votesCount = votes.length;
        assertEq(votesCount, 1);
        assertEq(votes[0].voter, voterAddress1);

        uint yesVotes = 0;
        uint noVotes = 0;

        for(uint i=0; i < votesCount; i++) {
            if(votes[i].decision == true) {
                yesVotes++;
            }
            else {
                noVotes++;
            }
        }
        assertEq(yesVotes, 1);
        assertEq(noVotes, 0); 
        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.stakedPool, 1);
 
    }

    function test_VoteOnBookTwice() public {
        truthChain.voteOnBook{value: 1 ether}(0, true);
        vm.expectRevert("You can only vote once per voting session!");
        truthChain.voteOnBook{value: 1 ether}(0, true);

        TruthChain.Vote[] memory votes = truthChain.getVotesForSession(0);
        uint votesCount = votes.length;

        uint yesVotes = 0;
        uint noVotes = 0;

        for(uint i=0; i < votesCount; i++) {
            if(votes[i].decision == true) {
                yesVotes++;
            }
            else {
                noVotes++;
            }
        }

        assertEq(yesVotes, 1);
        assertEq(noVotes, 0); 
        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.stakedPool, 1);
        assertEq(votingSession.active, true);
    }

    function test_endVotingSession() public {
        truthChain.endVotingSession(0);

        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.active, false);
    }

    function test_endVotingSessionAndTryToVote() public {
        truthChain.endVotingSession(0);

        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.active, false);

        vm.expectRevert("Voting session is closed.");
        truthChain.voteOnBook{value: 1 ether}(0, true);
    }
}
