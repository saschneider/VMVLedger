#
# Uploads controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  include QuorumTestHelper

  setup do
    @user          = users(:user1)
    @upload        = uploads(:election_parameters)
    @create_upload = Upload.new(election: @upload.election, file_type: @upload.file_type)
    @attachment    = fixture_file_upload('files/public-election-params.csv', 'text/csv')
  end

  test 'should not get index if not logged in' do
    get uploads_url
    assert_redirected_to new_user_session_path
  end

  test 'should get index if logged in' do
    sign_in @user

    get uploads_url
    assert_response :success
  end

  test 'should not show upload if not logged in' do
    get upload_url(@upload)
    assert_redirected_to new_user_session_path
  end

  test 'should show upload if logged in' do
    sign_in @user

    get upload_url(@upload)
    assert_response :success
  end

  test 'should get blockchain upload if not logged in if public election and public upload' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: true)
    @upload.public  = true
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    lines           = @upload.file.download.lines
    number_of_lines = lines.size

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum         = digest.base64digest
    @upload.checksum = checksum
    @upload.save!

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{filename},#{content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    get blockchain_upload_url(@upload)
    assert_response :success
  end

  test 'should not get blockchain upload if not logged in if public election but not public upload' do
    @upload.election.update!(public: true)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = false
    @upload.save!

    get blockchain_upload_url(@upload)
    assert_redirected_to root_path
  end

  test 'should not get blockchain upload if not logged in if not public election but public upload' do
    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = true
    @upload.save!

    get blockchain_upload_url(@upload)
    assert_redirected_to root_path
  end

  test 'should not get blockchain upload if logged in and no address' do
    sign_in @user

    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.address = nil
    @upload.save!

    get blockchain_upload_url(@upload)
    assert_redirected_to root_path
  end

  test 'should get blockchain upload if logged in' do
    sign_in @user

    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: false)
    @upload.public  = false
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    lines           = @upload.file.download.lines
    number_of_lines = lines.size

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum         = digest.base64digest
    @upload.checksum = checksum
    @upload.save!

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{filename},#{content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    get blockchain_upload_url(@upload)
    assert_response :success
  end

  test 'should get download upload if not logged in if public election and public upload' do
    @upload.election.update!(public: true)
    @upload.public = true
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.save!

    get download_upload_url(@upload)
    assert_response :success
  end

  test 'should not get download upload if not logged in if public election but not public upload' do
    @upload.election.update!(public: true)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = false
    @upload.save!

    get download_upload_url(@upload)
    assert_redirected_to root_path
  end

  test 'should not get download upload if not logged in if not public election but public upload' do
    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = true
    @upload.save!

    get download_upload_url(@upload)
    assert_redirected_to root_path
  end

  test 'should get download upload if logged in' do
    sign_in @user

    @upload.election.update!(public: false)
    @upload.public  = false
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.save!

    get download_upload_url(@upload)
    assert_response :success
  end

  test 'should not get new if not logged in' do
    get new_upload_url
    assert_redirected_to new_user_session_path
  end

  test 'should get new if logged in' do
    sign_in @user

    get new_upload_url
    assert_response :success
  end

  test 'should not create upload if not logged in' do
    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      assert_no_difference('Upload.count') do
        post uploads_url, params: { upload: @create_upload.attributes.merge(file: @attachment) }
      end
    end

    assert_redirected_to new_user_session_path
  end

  test 'should create upload if logged in but no blockchain commit' do
    @create_upload.public = false
    @create_upload.status = :creating

    sign_in @user

    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      assert_difference('Upload.count') do
        post uploads_url, params: { upload: @create_upload.attributes.merge(file: @attachment) }
      end
    end

    assert_redirected_to uploads_url

    upload = Upload.last
    assert upload.creating?
  end

  test 'should create upload if logged in with blockchain commit' do
    @create_upload.public = true
    @create_upload.status = :creating

    sign_in @user

    assert_enqueued_with(job: BlockchainCommitJob) do
      assert_difference('Upload.count') do
        post uploads_url, params: { upload: @create_upload.attributes.merge(file: @attachment) }
      end
    end

    assert_redirected_to uploads_url

    upload = Upload.last
    assert upload.creating?
  end

  test 'should not get edit if not logged in' do
    get edit_upload_url(@upload)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_upload_url(@upload)
    assert_response :success
  end

  test 'should not update upload if not logged in' do
    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      patch upload_url(@upload), params: { upload: @upload.attributes.merge(file: @attachment) }
      assert_redirected_to new_user_session_path
    end
  end

  test 'should update upload if logged in but not commit as not public' do
    sign_in @user

    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.update!(public: false)

    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      patch upload_url(@upload), params: { upload: @upload.attributes.merge(file: @attachment) }
      assert_redirected_to uploads_url
    end
  end

  test 'should update upload if logged in and commit as public' do
    sign_in @user

    assert_enqueued_with(job: BlockchainCommitJob) do
      patch upload_url(@upload), params: { upload: @upload.attributes.merge(file: @attachment) }
      assert_redirected_to uploads_url
    end
  end

  test 'should not recommit upload if not logged in' do
    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      post recommit_upload_url(@upload)
      assert_redirected_to new_user_session_path
    end
  end

  test 'should not recommit upload if logged in but upload not public' do
    sign_in @user

    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.update!(public: false)

    assert_no_enqueued_jobs(only: BlockchainCommitJob) do
      post recommit_upload_url(@upload)
      assert_redirected_to uploads_url
    end
  end

  test 'should recommit upload if logged in' do
    sign_in @user

    assert_enqueued_with(job: BlockchainCommitJob) do
      post recommit_upload_url(@upload)
      assert_redirected_to uploads_url
    end
  end

  test 'should not retrieve upload if not logged in' do
    assert_no_enqueued_jobs(only: BlockchainRetrieveJob) do
      post retrieve_upload_url(@upload)
      assert_redirected_to new_user_session_path
    end
  end

  test 'should not retrieve upload if logged in but upload not public' do
    sign_in @user

    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.update!(public: false, status: :success, address: '0x1234567890', checksum: 'checksum')

    assert_no_enqueued_jobs(only: BlockchainRetrieveJob) do
      post retrieve_upload_url(@upload)
      assert_redirected_to uploads_url
    end
  end

  test 'should retrieve upload if logged in' do
    sign_in @user

    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.update!(public: true, status: :success, address: '0x1234567890', checksum: 'checksum')

    assert_enqueued_with(job: BlockchainRetrieveJob) do
      post retrieve_upload_url(@upload)
      assert_redirected_to uploads_url
    end
  end
end
