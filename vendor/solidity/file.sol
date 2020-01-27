//
// File smart contract class.
//
// @author Matthew Casey
//
// (c) University of Surrey 2019
//

pragma solidity ^0.5.3;

//
// File contract which allows a multi-line file to be committed to the blockchain. The file is assumed to be composed of multiple chunks of strings.
//
contract File {

  // The number of chunks in the file.
  uint numberOfChunks = 0;
  
  // The mapping of chunks.
  mapping(uint => string) chunks;
  
  //
  // Adds a chunk to the file.
  //
  // @param chunk The chunk to be added.
  // @return The total number of chunks in the file.
  //
  function addChunk(string memory chunk) public returns (uint) {
    chunks[numberOfChunks] = chunk;
    numberOfChunks++;
    return numberOfChunks;
  }

  //
  // Retrieves a chunk from the file given its index.
  //
  // @param index The chunk index to be retrieved: >= 0 and < numberOfChunks.
  // @return The corresponding chunk.
  // @require That the index is valid.
  //
  function getChunk(uint index) public view returns (string memory) {
    require((index >= 0) && (index < numberOfChunks));
    return chunks[index];
  }
  
  //
  // @return The number of chunks.
  //
  function getNumberOfChunks() public view returns (uint) {
    return numberOfChunks;
  }
}