#
# Blockchain commit job test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class BlockchainCommitJobTest < ActiveJob::TestCase
  include QuorumTestHelper

  setup do
    @upload = uploads(:election_parameters)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')

    @file_type_public     = file_types(:election_parameters)
    @file_type_not_public = file_types(:not_public)
  end

  test 'should not commit with non public file' do
    @upload.update!(public: false, file_type: @file_type_public, status: :creating, address: nil)

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_commit_job.not_public', upload: @upload.id), e.message

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit with non public file type' do
    @upload.update!(public: false, file_type: @file_type_not_public, status: :creating, address: nil)

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_commit_job.not_public', upload: @upload.id), e.message

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as status pending' do
    @upload.update!(public: true, file_type: @file_type_public, status: :pending, address: nil)

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_commit_job.duplicate_upload', upload: @upload.id), e.message

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as status success' do
    @upload.update!(public: true, file_type: @file_type_public, status: :success, address: '0x123456789', checksum: 'checksum')

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_commit_job.duplicate_upload', upload: @upload.id), e.message

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as has contract address' do
    @upload.update!(public: true, file_type: @file_type_public, status: :creating, address: '0x123456789', checksum: 'checksum')

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert_equal I18n.t('blockchain_commit_job.duplicate_upload', upload: @upload.id), e.message

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as no url' do
    Service.get_service.update!(nodes: nil)
    @upload.update!(public: true, file_type: @file_type_public, status: :creating, address: nil)

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert e.message.start_with? I18n.t('blockchain_commit_job.failed_upload', upload: '')

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as fail create contract' do
    @upload.update!(public: true, file_type: @file_type_public, status: :creating, address: nil)

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT, [true, true, true])

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert e.message.start_with? I18n.t('blockchain_commit_job.failed_perform', upload: '', message: '').strip

    @upload.reload
    assert @upload.failed?
  end

  test 'should not commit as fail upload to contract' do
    @upload.update!(public: true, file_type: @file_type_public, status: :creating, address: nil)
    number_of_lines = @upload.file.download.lines.size

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT)
    stub_transact_contract(self, url, contract_address, [true, true])
    stub_call_contract(self, url, [0.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), (number_of_lines + 1).to_s(16)])

    e = assert_raises ApplicationJob::JobError do
      assert_no_enqueued_jobs only: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    assert e.message.start_with? I18n.t('blockchain_commit_job.failed_perform', upload: '', message: '').strip

    @upload.reload
    assert @upload.failed?
  end

  test 'should commit' do
    @upload.update!(public: true, file_type: @file_type_public, status: :creating, address: nil)
    number_of_lines = @upload.file.download.lines.size

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    contract_address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, contract_address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT)
    stub_transact_contract(self, url, contract_address)
    stub_call_contract(self, url, [0.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), (number_of_lines + 1).to_s(16)])

    assert_nothing_raised do
      assert_enqueued_with job: BlockchainRetrieveJob do
        BlockchainCommitJob.perform_now(@upload.id)
      end
    end

    @upload.reload
    assert @upload.success?
  end
end