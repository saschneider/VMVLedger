#
# Contents controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class ContentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include QuorumTestHelper

  setup do
    @user   = users(:user1)
    @upload = uploads(:election_parameters)
  end

  test 'should get index if not logged in if public election and public upload' do
    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: true)
    @upload.public  = true
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    get upload_contents_url(@upload)
    assert_response :success
  end

  test 'should not get index if not logged in if public election but not public upload' do
    @upload.election.update!(public: true)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = false
    @upload.save!

    get upload_contents_url(@upload)
    assert_redirected_to root_path
  end

  test 'should not get index if not logged in if not public election but public upload' do
    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = true
    @upload.save!

    get upload_contents_url(@upload)
    assert_redirected_to root_path
  end

  test 'should not get index if logged in and no address' do
    sign_in @user

    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.address = nil
    @upload.save!

    get upload_contents_url(@upload)
    assert_redirected_to root_path
  end

  test 'should get index if logged in' do
    sign_in @user

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: false)
    @upload.public  = false
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    get upload_contents_url(@upload)
    assert_response :success
  end

  test 'should get show if not logged in if public election and public upload' do
    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: true)
    @upload.public  = true
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    get content_url(@upload.contents.first)
    assert_response :success
  end

  test 'should not get show if not logged in if public election but not public upload' do
    @upload.election.update!(public: true)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = false
    @upload.save!

    get content_url(@upload.contents.first)
    assert_redirected_to root_path
  end

  test 'should not get show if not logged in if not public election but public upload' do
    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.public = true
    @upload.save!

    get content_url(@upload.contents.first)
    assert_redirected_to root_path
  end

  test 'should not get show if logged in and no address' do
    sign_in @user

    @upload.election.update!(public: false)
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    @upload.address = nil
    @upload.save!

    get content_url(@upload.contents.first)
    assert_redirected_to root_path
  end

  test 'should get show if logged in' do
    sign_in @user

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    @upload.election.update!(public: false)
    @upload.public  = false
    @upload.address = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    @upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    @upload.save!

    get content_url(@upload.contents.first)
    assert_response :success
  end
end
