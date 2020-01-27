#
# Quorum test helper module.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module QuorumTestHelper

  # Test contract with nested transaction and file contract.
  class TestContract

    attr_reader :address

    class Transaction

      def mined?
        true
      end

    end

    class FileContract

      def initialize(chunks)
        @chunks = chunks
      end

      def get_number_of_chunks
        @chunks.size
      end

      def get_chunk(index)
        @chunks[index]
      end

      def add_chunk(chunk)
        @chunks << chunk
        Transaction.new
      end
    end

    def initialize(chunks)
      @file = FileContract.new(chunks)
    end

    def call
      @file
    end

    def transact
      @file
    end
  end

  #
  # Stubs a Quorum contract create.
  #
  # @param test The test object.
  # @param url The Quorum node URL.
  # @param code The contract bytecode.
  # @param contract_address The created contract address.
  # @param gas_price The contract gas price.
  # @param gas_limit The contract gas limit.
  # @param error Should each call fail?
  #
  def stub_create_contract(test, url, code, contract_address, gas_price, gas_limit, error = [false, false, false])
    stub = test.stub_request(:post, url)
             .with(body: { jsonrpc: '2.0', method: 'eth_accounts', params: [], id: 1 })
    error[0] ? stub.to_timeout : stub.to_return(status: 200, body: { 'id': 1, 'jsonrpc': '2.0', 'result': ['0xc94770007dda54cF92009BFF0dE90c06F603a09f'] }.to_json)

    stub = test.stub_request(:post, url)
             .with(body:    { jsonrpc: '2.0', method: 'eth_sendTransaction', params: [{ from: '0xc94770007dda54cF92009BFF0dE90c06F603a09f', data: "0x#{code}", gas: "0x#{gas_limit.to_s(16)}", gasPrice: "0x#{gas_price.to_s(16)}" }], id: 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    error[1] ? stub.to_timeout : stub.to_return(status: 200, body: { jsonrpc: '2.0', id: 1, result: '0x3311ae53381ab5ebe1a8ff34fe56443deec4ad501d916b4f078f585b36ab207a' }.to_json)

    stub = test.stub_request(:post, url)
             .with(body:    { jsonrpc: '2.0', method: 'eth_getTransactionReceipt', params: ['0x3311ae53381ab5ebe1a8ff34fe56443deec4ad501d916b4f078f585b36ab207a'], 'id': 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    error[2] ? stub.to_timeout : stub.to_return(status: 200, body: { jsonrpc: '2.0', id: 1, result: { blockHash: '0xdf3b945392bd3417e8469660dd07dee45feaf65bfb3fe272e9aa6f0c93899988', blockNumber: '0x1f20', contractAddress: contract_address, cumulativeGasUsed: '0x472c7', from: '0xed9d02e382b34818e88b88a309c7fe71e65f419d', gasUsed: '0x472c7', logs: [], logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', status: '0x1', to: nil, transactionHash: '0xa85ab1821729a9dfd25579dd512c2ac5763de9dba6e4447d05c95585ebe85d2f', transactionIndex: '0x0' } }.to_json)
  end

  #
  # Stubs a Quorum contract get.
  #
  # @param test The test object.
  # @param url The Quorum node URL.
  # @param error Should the call fail?
  #
  def stub_get_contract(test, url, error = false)
    stub = test.stub_request(:post, url)
             .with(body: { jsonrpc: '2.0', method: 'eth_accounts', params: [], id: 1 })
    error ? stub.to_timeout : stub.to_return(status: 200, body: { 'id': 1, 'jsonrpc': '2.0', 'result': ['0xc94770007dda54cF92009BFF0dE90c06F603a09f'] }.to_json)
  end

  #
  # Stubs a Quorum contract call.
  #
  # @param test The test object.
  # @param url The Quorum node URL.
  # @param results An array of results to be sent back via the stub.
  # @param error Should the call fail?
  #
  def stub_call_contract(test, url, results, error = false)
    results = [results] unless results.is_a?(Array)
    returns = results.map { |result| { status: 200, body: { jsonrpc: '2.0', id: 1, result: result }.to_json } }

    stub = test.stub_request(:post, url)
             .with(
               body:    hash_including({ jsonrpc: '2.0', method: 'eth_call', 'id': 1 }),
               headers: { 'Content-Type' => 'application/json' })
    error ? stub.to_timeout : stub.to_return(returns)
  end

  #
  # Stubs a Quorum contract transact.
  #
  # @param test The test object.
  # @param url The Quorum node URL.
  # @param contract_address The existing contract address.
  # @param error Should each call fail?
  #
  def stub_transact_contract(test, url, contract_address, error = [false, false])
    stub = test.stub_request(:post, url)
             .with(body:    hash_including({ jsonrpc: '2.0', method: 'eth_sendTransaction', id: 1 }),
                   headers: { 'Content-Type' => 'application/json' })
    error[0] ? stub.to_timeout : stub.to_return(status: 200, body: { jsonrpc: '2.0', id: 1, result: '0x3311ae53381ab5ebe1a8ff34fe56443deec4ad501d916b4f078f585b36ab207a' }.to_json)

    stub = test.stub_request(:post, url)
             .with(body:    { jsonrpc: '2.0', method: 'eth_getTransactionReceipt', params: ['0x3311ae53381ab5ebe1a8ff34fe56443deec4ad501d916b4f078f585b36ab207a'], 'id': 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    error[1] ? stub.to_timeout : stub.to_return(status: 200, body: { jsonrpc: '2.0', id: 1, result: { blockHash: '0xdf3b945392bd3417e8469660dd07dee45feaf65bfb3fe272e9aa6f0c93899988', blockNumber: '0x1f20', contractAddress: contract_address, cumulativeGasUsed: '0x472c7', from: '0xed9d02e382b34818e88b88a309c7fe71e65f419d', gasUsed: '0x472c7', logs: [], logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', status: '0x1', to: nil, transactionHash: '0xa85ab1821729a9dfd25579dd512c2ac5763de9dba6e4447d05c95585ebe85d2f', transactionIndex: '0x0' } }.to_json)

    stub = test.stub_request(:post, url)
             .with(body:    { jsonrpc: '2.0', method: 'eth_getTransactionByHash', params: ['0x3311ae53381ab5ebe1a8ff34fe56443deec4ad501d916b4f078f585b36ab207a'], 'id': 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    error[1] ? stub.to_timeout : stub.to_return(status: 200, body: { jsonrpc: '2.0', id: 1, result: { blockHash: '0xdf3b945392bd3417e8469660dd07dee45feaf65bfb3fe272e9aa6f0c93899988', blockNumber: '0x1f20', contractAddress: contract_address, cumulativeGasUsed: '0x472c7', from: '0xed9d02e382b34818e88b88a309c7fe71e65f419d', gasUsed: '0x472c7', logs: [], logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', status: '0x1', to: nil, transactionHash: '0xa85ab1821729a9dfd25579dd512c2ac5763de9dba6e4447d05c95585ebe85d2f', transactionIndex: '0x0' } }.to_json)
  end
end