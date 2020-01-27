#
# Service model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ServiceTest < ActiveSupport::TestCase

  test 'should not save if invalid' do
    service = Service.new

    service.ui_enabled               = nil
    service.jobs_enabled             = nil
    service.download_from_blockchain = nil
    service.retrieve_interval        = nil

    service.save
    refute service.valid?
  end

  test 'should save if valid' do
    service = Service.new

    service.ui_enabled               = true
    service.jobs_enabled             = true
    service.download_from_blockchain = true
    service.retrieve_interval        = 'PT5M'

    service.save
    assert service.valid?
  end

  test 'should get service' do
    assert_not_nil Service.get_service
  end

  test 'should get service even if missing record' do
    Service.destroy_all
    assert_not_nil Service.get_service
  end

  test 'should get random node' do
    nodes = ['http://localhost:22000', 'http://localhost:22001', 'http://localhost:22002']

    service                          = Service.new
    service.ui_enabled               = true
    service.jobs_enabled             = true
    service.nodes                    = nodes.join(',')
    service.download_from_blockchain = true
    service.retrieve_interval        = 'PT5M'
    service.save
    assert service.valid?

    assert nodes.include?(service.get_random_node)
  end

  test 'should get fields' do
    nodes = 'http://localhost:22000,http://localhost:22001'

    service                          = Service.new
    service.ui_enabled               = true
    service.jobs_enabled             = true
    service.nodes                    = nodes
    service.download_from_blockchain = true
    service.retrieve_interval        = 'PT5M'
    service.verify_email             = 'test@test.com'
    service.full_length_field        = 'testField1;testField2'
    service.save
    assert service.valid?

    service.reload
    assert service.ui_enabled?
    assert service.jobs_enabled?
    assert_equal nodes, service.nodes
    assert service.download_from_blockchain?
    assert_equal 'PT5M', service.retrieve_interval
    assert_equal 5.minutes, service.retrieve_interval_duration
    assert_equal 'test@test.com', service.verify_email
    assert_equal 'testField1;testField2', service.full_length_field
  end
end
