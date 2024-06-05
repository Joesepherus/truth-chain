pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TruthChain} from "../src/TruthChain.sol";

contract TruthChainTest is Test {
    TruthChain public truthChain;

    function setUp() public {
        truthChain = new TruthChain();
    }

    function test_CreateBook() public view {
        truthChain.createBook(
            "book 1"
        );
    }

}
