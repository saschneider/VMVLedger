#
# Quorum helper test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class QuorumHelperTest < ActiveSupport::TestCase
  include QuorumTestHelper

  class TestQuorumHelper < QuorumHelper

    def public_create_contract(name, abi, code, options = {})
      create_contract(name, abi, code, options)
    end

    def public_get_contract(name, abi, address, options = {})
      get_contract(name, abi, address, options)
    end
  end

  # File contract constants. See vendor/solidity for contract source.
  CONTRACT_NAME      = 'ContractFile'
  CONTRACT_FILE_ABI  = [{ 'constant': true, 'inputs': [], 'name': 'getNumberOfChunks', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': 'index', 'type': 'uint256' }], 'name': 'getChunk', 'outputs': [{ 'name': '', 'type': 'string' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': 'chunk', 'type': 'string' }], 'name': 'addChunk', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }].freeze
  CONTRACT_FILE_CODE = '60806040526000805534801561001457600080fd5b506103e9806100246000396000f3fe608060405234801561001057600080fd5b506004361061005e576000357c0100000000000000000000000000000000000000000000000000000000900480631e509f41146100635780636d2f923b1461008157806375b37eea14610128575b600080fd5b61006b6101f7565b6040518082815260200191505060405180910390f35b6100ad6004803603602081101561009757600080fd5b8101908080359060200190929190505050610200565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100ed5780820151818401526020810190506100d2565b50505050905090810190601f16801561011a5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101e16004803603602081101561013e57600080fd5b810190808035906020019064010000000081111561015b57600080fd5b82018360208201111561016d57600080fd5b8035906020019184600183028401116401000000008311171561018f57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192905050506102d2565b6040518082815260200191505060405180910390f35b60008054905090565b606060008210158015610214575060005482105b151561021f57600080fd5b600160008381526020019081526020016000208054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102c65780601f1061029b576101008083540402835291602001916102c6565b820191906000526020600020905b8154815290600101906020018083116102a957829003601f168201915b50505050509050919050565b600081600160008054815260200190815260200160002090805190602001906102fc929190610318565b5060008081548092919060010191905055506000549050919050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061035957805160ff1916838001178555610387565b82800160010185558215610387579182015b8281111561038657825182559160200191906001019061036b565b5b5090506103949190610398565b5090565b6103ba91905b808211156103b657600081600090555060010161039e565b5090565b9056fea165627a7a723058204ea3316af4f32c0a4eec90ee66fabde4904637b93cf60e061543ffd5e59d560c0029'.freeze

  test 'should initialise' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    assert_equal url, helper.url
  end

  test 'should not create contract fail accounts' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, CONTRACT_FILE_CODE, contract_address, gas_price, gas_limit, [true, false, false])

    e = assert_raises QuorumHelper::QuorumError do
      helper.public_create_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, CONTRACT_FILE_CODE, gas_price: gas_price, gas_limit: gas_limit)
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should not create contract fail send transaction' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, CONTRACT_FILE_CODE, contract_address, gas_price, gas_limit, [false, true, false])

    e = assert_raises QuorumHelper::QuorumError do
      helper.public_create_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, CONTRACT_FILE_CODE, gas_price: gas_price, gas_limit: gas_limit)
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should not create contract fail get transaction receipt' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, CONTRACT_FILE_CODE, contract_address, gas_price, gas_limit, [false, false, true])

    e = assert_raises QuorumHelper::QuorumError do
      helper.public_create_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, CONTRACT_FILE_CODE, gas_price: gas_price, gas_limit: gas_limit)
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should create contract' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, CONTRACT_FILE_CODE, contract_address, gas_price, gas_limit)

    contract = helper.public_create_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, CONTRACT_FILE_CODE, gas_price: gas_price, gas_limit: gas_limit)
    assert_not_nil contract

    assert_equal gas_price, contract.gas_price
    assert_equal gas_limit, contract.gas_limit
    assert_equal contract_address, contract.address
  end

  test 'should not get contract fail accounts' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_get_contract(self, url, true)

    e = assert_raises QuorumHelper::QuorumError do
      helper.public_get_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, contract_address, gas_price: gas_price, gas_limit: gas_limit)
    end

    assert e.message.start_with? I18n.t('quorum_helper.get_contract_failed', url: url, message: '')
  end

  test 'should get contract' do
    url    = 'http://localhost:22000'
    helper = TestQuorumHelper.new(url)
    assert_not_nil helper

    gas_price        = 0
    gas_limit        = 4_000_000
    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_get_contract(self, url)

    contract = helper.public_get_contract(CONTRACT_NAME, CONTRACT_FILE_ABI, contract_address, gas_price: gas_price, gas_limit: gas_limit)
    assert_not_nil contract

    assert_equal gas_price, contract.gas_price
    assert_equal gas_limit, contract.gas_limit
    assert_equal contract_address, contract.address
  end

  test 'should get wrapper' do
    assert_equal CSVFileWrapper.name, QuorumFileHelper.wrapper_for_content('text/csv')
    assert_equal BinaryFileWrapper.name, QuorumFileHelper.wrapper_for_content('text/xml')
    assert_equal BinaryFileWrapper.name, QuorumFileHelper.wrapper_for_content('application/zip')
    assert_equal BinaryFileWrapper.name, QuorumFileHelper.wrapper_for_content('rubbish/rubbish')
  end
end