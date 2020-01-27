#
# Blockchain retrieve job test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class BlockchainRetrieveJobTest < ActiveJob::TestCase
  include QuorumTestHelper

  setup do
    @upload       = uploads(:election_parameters)
    @filename     = 'public-election-params.csv'
    @content_type = 'text/csv'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: @filename, content_type: @content_type)

    @file_type_public     = file_types(:election_parameters)
    @file_type_not_public = file_types(:not_public)
  end

  test 'should not retrieve with non public file' do
    @upload.update!(public: false, file_type: @file_type_public, status: :creating, address: nil)

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    e = assert_raises ApplicationJob::JobError do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_retrieve_job.not_public', upload: @upload.id), e.message

    @upload.reload
    assert_equal 0, @upload.contents.count
    assert_nil @upload.retrieved_at
  end

  test 'should not retrieve with non public file type' do
    @upload.update!(public: false, file_type: @file_type_not_public, status: :creating, address: nil)

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    e = assert_raises ApplicationJob::JobError do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_retrieve_job.not_public', upload: @upload.id), e.message

    @upload.reload
    assert_equal 0, @upload.contents.count
    assert_nil @upload.retrieved_at
  end

  test 'should not retrieve as status not success' do
    @upload.update!(public: true, file_type: @file_type_public, status: :pending, address: nil)

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    e = assert_raises ApplicationJob::JobError do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_retrieve_job.not_uploaded', upload: @upload.id), e.message

    @upload.reload
    assert_equal 0, @upload.contents.count
    assert_nil @upload.retrieved_at
  end

  test 'should not retrieve as no url' do
    Service.get_service.update!(nodes: nil)
    @upload.update!(public: true, file_type: @file_type_public, status: :success, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum')

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    e = assert_raises ApplicationJob::JobError do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    assert e.message.start_with? I18n.t('blockchain_retrieve_job.failed_download', upload: '')

    @upload.reload
    assert_equal 0, @upload.contents.count
    assert_nil @upload.retrieved_at
  end

  test 'should not retrieve as fail get from contract' do
    @upload.update!(public: true, file_type: @file_type_public, status: :success, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum')

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    stub_get_contract(self, url)
    stub_call_contract(self, url, [], true)

    e = assert_raises ApplicationJob::JobError do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    assert e.message.start_with? I18n.t('blockchain_retrieve_job.failed_perform', upload: '', message: '').strip

    @upload.reload
    assert_equal 0, @upload.contents.count
    assert_nil @upload.retrieved_at
  end

  test 'should retrieve' do
    @upload.update!(public: true, file_type: @file_type_public, status: :success, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum')
    lines           = @upload.file.download.lines
    number_of_lines = lines.size

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum         = digest.base64digest
    @upload.checksum = checksum
    @upload.save!

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{@filename},#{@content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    assert_nothing_raised do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now(@upload.id)
      end
    end

    @upload.reload
    assert_equal number_of_lines, @upload.contents.count
    assert_not_nil @upload.retrieved_at
  end

  test 'should not retrieve as no upload ready' do
    Service.get_service.update(retrieve_interval: 'PT60M')

    now = Time.current
    Upload.update_all(retrieved_at: now)

    assert_nothing_raised do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now
      end
    end

    assert_equal 0, Upload.where('retrieved_at != ?', now).count
  end

  test 'should retrieve as upload ready' do
    Service.get_service.update(retrieve_interval: 'PT60M')

    now = Time.current
    Upload.update_all(retrieved_at: now)

    @upload.update!(public: true, file_type: @file_type_public, status: :success, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: now - Service.get_service.retrieve_interval_duration)
    lines           = @upload.file.download.lines
    number_of_lines = lines.size

    @upload.contents.destroy_all
    assert_equal 0, @upload.contents.count

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum         = digest.base64digest
    @upload.checksum = checksum
    @upload.save!

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{@filename},#{@content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    assert_nothing_raised do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainRetrieveJob.perform_now
      end
    end

    @upload.reload
    assert_equal 1, Upload.where('retrieved_at != ?', now).count
    assert_not_equal now - Service.get_service.retrieve_interval_duration, @upload.retrieved_at
  end
end