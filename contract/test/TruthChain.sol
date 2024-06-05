pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TruthChain} from "../src/TruthChain.sol";

contract TruthChainTest is Test {
    TruthChain public truthChain;

    function setUp() public {
        truthChain = new TruthChain();
    }

    function test_CreateBook() public {
        TruthChain.Book memory book = truthChain.createBook(
            "book 1"
        );

        uint bookCount = truthChain.bookCount();
        assertEq(bookCount, 1);
        assertEq(book.id, 0);
        assertEq(book.title, "book 1");
    }

}
