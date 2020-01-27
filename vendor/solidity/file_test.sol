//
// File smart contract remix test class.
//
// @author Matthew Casey
//
// (c) University of Surrey 2019
//

pragma solidity ^0.5.3;

import "remix_tests.sol";
import "./file.sol";

//
// File contract tests.
//
contract FileTest {

  //
  // Test adding chunks.
  //
  function testAddChunk() public {
    File file = new File();

    Assert.equal(file.getNumberOfChunks(), 0, "should have 0 chunks");

    for (uint i = 1; i <= 2; i++) {
      Assert.equal(file.addChunk("Test Chunk"), i, "should add chunk");
    }
  }
  
  //
  // Test getting chunks.
  //
  function testGetChunk() public {
    File file = new File();

    Assert.equal(file.getNumberOfChunks(), 0, "should have 0 chunks");

    Assert.equal(file.addChunk("0123456789"), 1, "should add chunk 1");
    Assert.equal(file.getChunk(0), "0123456789", "should get chunk 1");

    Assert.equal(file.addChunk("01234567890123456789"), 2, "should add chunk 2");
    Assert.equal(file.getChunk(1), "01234567890123456789", "should get chunk 2");
  }
}
