#
# Quorum helper class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class QuorumHelper

  # Error that will be raised if the helper fails.
  class QuorumError < StandardError
  end

  # The Quorum node URL.
  attr_reader :url

  #
  # Initialises the object.
  #
  # @param url The Quorum node URL.
  #
  def initialize(url)
    @url    = url
    @client = nil
  end

  protected

  #
  # Creates a new contract object using the provided ABI and bytecode.
  #
  # @param name The name of the corresponding Ruby class for the contract.
  # @param abi The contract ABI.
  # @param code The contract bytecode.
  # @param options Options to apply to the contract. Includes :gas_price (default 0) and :gas_limit (default 4000000).
  # @return The new contract object.
  #
  def create_contract(name, abi, code, options = {})
    gas_price = options[:gas_price] ? options[:gas_price] : 0
    gas_limit = options[:gas_limit] ? options[:gas_limit] : 4_000_000

    # Create the contract object.
    contract = Ethereum::Contract.create(name: name, abi: abi.to_json, code: code, client: get_client)

    # Set the required contract gas values.
    contract.gas_price = gas_price
    contract.gas_limit = gas_limit

    # Deploy the contract.
    contract.deploy_and_wait

    contract
  rescue => e
    raise QuorumError, I18n.t('quorum_helper.create_contract_failed', url: @url, message: e.message)
  end

  #
  # Attempts to create the quorum node client, if a client has not already been created.
  #
  # @return The Quorum client.
  #
  def get_client
    @client = Ethereum::Client.create(@url) if @client.nil?
    @client
  end

  #
  # Obtains an existing contract object from an address.
  #
  # @param name The name of the corresponding Ruby class for the contract.
  # @param abi The contract ABI.
  # @param address The address of the existing contract object.
  # @param options Options to apply to the contract. Includes :gas_price (default 0) and :gas_limit (default 4000000).
  # @return The contract object.
  #
  def get_contract(name, abi, address, options = {})
    gas_price = options[:gas_price] ? options[:gas_price] : 0
    gas_limit = options[:gas_limit] ? options[:gas_limit] : 4_000_000

    # Get the contract object.
    contract = Ethereum::Contract.create(name: name, address: address, abi: abi.to_json, client: get_client)

    # Set the required contract gas values.
    contract.gas_price = gas_price
    contract.gas_limit = gas_limit

    contract
  rescue => e
    raise QuorumError, I18n.t('quorum_helper.get_contract_failed', url: @url, message: e.message)
  end
end