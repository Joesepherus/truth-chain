pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TruthChain} from "../src/TruthChain.sol";

contract TruthChainTest is Test {
    TruthChain public truthChain;
    address constant ownerAddress = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
    address constant voterAddress1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant voterAddress2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant voterAddress3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant voterAddress4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address constant voterAddress5 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

    function setUp() public {
        vm.prank(ownerAddress);
        truthChain = new TruthChain();
        vm.deal(ownerAddress, 1000 ether);
        vm.deal(voterAddress1, 100 ether);
        vm.deal(voterAddress2, 100 ether);
        vm.deal(voterAddress3, 100 ether);
        vm.deal(voterAddress4, 100 ether);
        vm.deal(voterAddress5, 100 ether);

        vm.prank(ownerAddress);
        truthChain.createBook(
            "book 1"
        );

        vm.prank(ownerAddress);
        truthChain.createVotingSession(0);

        vm.prank(ownerAddress);
        truthChain.deposit{value: 1000 ether}();

        vm.prank(voterAddress1);
        truthChain.deposit{value: 10 ether}();
        
        vm.prank(voterAddress2);
        truthChain.deposit{value: 10 ether}();
        vm.prank(voterAddress3);
        truthChain.deposit{value: 10 ether}();
        vm.prank(voterAddress4);
        truthChain.deposit{value: 10 ether}();
        vm.prank(voterAddress5);
        truthChain.deposit{value: 10 ether}();
    }

    function test_CreateBook() public {
        vm.prank(ownerAddress);
        TruthChain.Book memory book = truthChain.createBook(
            "book 2"
        );

        uint bookCount = truthChain.bookCount();
        assertEq(bookCount, 2);
        assertEq(book.id, 1);
        assertEq(book.title, "book 2");
   }


    function test_CreateBookNotAsOwner() public {
        vm.prank(voterAddress1);
        vm.expectRevert("You need to be an owner for this operation.");
        truthChain.createBook(
            "book 3"
        );
   }

    function test_CreateVotingSession() public {
        vm.prank(ownerAddress);
        TruthChain.VotingSession memory votingSession = truthChain.createVotingSession(0);
        
        uint votingSessionCount = truthChain.votingSessionCount();
        assertEq(votingSessionCount, 2);
        assertEq(votingSession.id, 1);
        assertEq(votingSession.active, true);
    }

    function test_CreateVotingSessionNotAsOwner() public {
        vm.prank(voterAddress1);
        vm.expectRevert("You need to be an owner for this operation.");
        TruthChain.VotingSession memory votingSession = truthChain.createVotingSession(0);
    }

    function test_VoteOnBook() public {
        uint balance = truthChain.getBalance(voterAddress1);
        assertEq(balance, 10000000000000000000);
        vm.prank(voterAddress1);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress1);
        truthChain.voteOnBook(0, true);
        uint balance2 = truthChain.getBalance(voterAddress1);
        assertEq(balance2, 4000000000000000000);
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
        uint balance = truthChain.getBalance(voterAddress1);
        assertEq(balance, 10000000000000000000);
        vm.prank(voterAddress1);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress1);
        truthChain.voteOnBook(0, true);
        vm.prank(voterAddress1);
        vm.expectRevert("You can only vote once per voting session!");
        truthChain.voteOnBook(0, true);

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
        vm.prank(ownerAddress);
        truthChain.endVotingSession(0);

        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.active, false);
    }

    function test_endVotingSessionAsNotOwner() public {
        vm.prank(voterAddress1);
        vm.expectRevert("You need to be an owner for this operation.");
        truthChain.endVotingSession(0);
    }

    function test_endVotingSessionAndTryToVote() public {
        vm.prank(ownerAddress);
        truthChain.endVotingSession(0);

        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.active, false);

        vm.prank(voterAddress1);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress1);
        vm.expectRevert("Voting session is closed.");
        truthChain.voteOnBook{value: 1 ether}(0, true);
    }

    function test_distributeCoins() public {
        vm.prank(voterAddress1);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress1);
        truthChain.voteOnBook(0, true);
        vm.prank(voterAddress2);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress2);
        truthChain.voteOnBook(0, true);
        vm.prank(voterAddress3);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress3);
        truthChain.voteOnBook(0, true);
        vm.prank(voterAddress4);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress4);
        truthChain.voteOnBook(0, false);
        vm.prank(voterAddress5);
        truthChain.lockCoins(5000000000000000000);
        vm.prank(voterAddress5);
        truthChain.voteOnBook(0, false);
        vm.prank(ownerAddress);
        truthChain.endVotingSession(0);
        truthChain.distributeCoins(0);
        TruthChain.VotingSession memory votingSession = truthChain.getVotingSessionById(0);
        assertEq(votingSession.distributed, true);
        uint balance = truthChain.getBalance(voterAddress1);
        //                10000000000000000000 total
        //                 5000000000000000000 lockedup
        //                 1000000000000000000 invested
        //                 4000000000000000000 left
        //                  833333333333333332 reward              
        // because 5/3 = 1.6666666666
        // and 1.6666666666 * 0.1 = 0.166666666666666
        // and 1.666666666 + 0.1666666666666 = 1.83333333333333332
        //                10000000000000000000 + 1833333333333333332
        assertEq(balance, 5833333333333333332);
        uint balance2 = truthChain.getBalance(voterAddress2);
        assertEq(balance2, 5833333333333333332);
        uint balance5 = truthChain.getBalance(voterAddress5);
        assertEq(balance5, 4000000000000000000);
    }
}
