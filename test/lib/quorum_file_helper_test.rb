#
# Quorum file helper test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class QuorumFileHelperTest < ActiveSupport::TestCase
  include QuorumTestHelper

  test 'should initialise' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    assert_equal url, helper.url
  end

  test 'should not create fail accounts' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT, [true, false, false])

    e = assert_raises QuorumHelper::QuorumError do
      helper.create
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should not create fail send transaction' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT, [false, true, false])

    e = assert_raises QuorumHelper::QuorumError do
      helper.create
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should not create fail get transaction receipt' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT, [false, false, true])

    e = assert_raises QuorumHelper::QuorumError do
      helper.create
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should create' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT)

    file = helper.create
    assert_not_nil file
  end

  test 'should not get fail accounts' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_get_contract(self, url, true)

    e = assert_raises QuorumHelper::QuorumError do
      helper.get(contract_address)
    end

    assert e.message.start_with? I18n.t('quorum_helper.get_contract_failed', url: url, message: '')
  end

  test 'should get' do
    url    = 'http://localhost:22000'
    helper = QuorumFileHelper.new(url)
    assert_not_nil helper

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_get_contract(self, url)

    file = helper.get(contract_address)
    assert_not_nil file
  end
end