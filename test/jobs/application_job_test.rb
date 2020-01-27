#
# Application job test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ApplicationJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  class TestJob < ApplicationJob
    attr_accessor :performed

    def perform_if_enabled
      @performed = true
    end
  end

  test 'should not perform job if jobs disabled' do
    Service.get_service.update(jobs_enabled: false)

    job = TestJob.new

    assert_enqueued_with(job: TestJob) do
      job.perform
    end

    refute job.performed
  end

  test 'should perform job if jobs enabled' do
    Service.get_service.update(jobs_enabled: true)

    job = TestJob.new

    assert_no_enqueued_jobs do
      job.perform
    end

    assert job.performed
  end

end