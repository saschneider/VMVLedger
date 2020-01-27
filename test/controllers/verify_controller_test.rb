#
# Verify controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'csv'

class VerifyControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user             = users(:user1)
    @public_election  = elections(:public_election)
    @private_election = elections(:private_election)

    @public_election.uploads.destroy_all
    FileType.destroy_all

    file_type = FileType.create!(name: 'Election Parameters', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 1)
    upload    = @public_election.uploads.new(file_type: file_type, status: :success, public: true, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: Time.current)
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: file_type.content_type)
    upload.save!

    sequence = 0
    CSV.foreach('test/fixtures/files/public-election-params.csv') do |row|
      content = upload.contents.new(sequence: sequence)
      row.each_with_index { |value, i| content[Content.field_index_to_sym(i)] = value }
      content.save!
      sequence += 1
    end

    file_type = FileType.create!(name: "Voters' Keys", action: :no_action, public: false, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 5)
    upload    = @public_election.uploads.new(file_type: file_type, public: false)
    upload.file.attach(io: File.open('test/fixtures/files/voters-keys.csv'), filename: 'voters-keys.csv', content_type: file_type.content_type)
    upload.save!

    file_type = FileType.create!(name: 'Voter Public Keys with Encrypted Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_status: true, sequence: 13)
    upload    = @public_election.uploads.new(file_type: file_type, status: :success, public: true, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: Time.current)
    upload.file.attach(io: File.open('test/fixtures/files/public-voters.csv'), filename: 'public-voters.csv', content_type: file_type.content_type)
    upload.save!

    sequence = 0
    CSV.foreach('test/fixtures/files/public-voters.csv') do |row|
      content = upload.contents.new(sequence: sequence)
      row.each_with_index { |value, i| content[Content.field_index_to_sym(i)] = value }
      content.save!
      sequence += 1
    end

    file_type = FileType.create!(name: 'Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 7)
    upload    = @public_election.uploads.new(file_type: file_type, status: :success, public: true, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: Time.current)
    upload.file.attach(io: File.open('test/fixtures/files/public-tracker-numbers.csv'), filename: 'public-tracker-numbers.csv', content_type: file_type.content_type)
    upload.save!

    sequence = 0
    CSV.foreach('test/fixtures/files/public-tracker-numbers.csv') do |row|
      content = upload.contents.new(sequence: sequence)
      row.each_with_index { |value, i| content[Content.field_index_to_sym(i)] = value }
      content.save!
      sequence += 1
    end

    file_type = FileType.create!(name: 'Encrypted Votes with Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, needed_for_status: true, sequence: 16)
    upload    = @public_election.uploads.new(file_type: file_type, status: :success, public: true, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: Time.current)
    upload.file.attach(io: File.open('test/fixtures/files/public-encrypted-voters.csv'), filename: 'public-encrypted-voters.csv', content_type: file_type.content_type)
    upload.save!

    sequence = 0
    CSV.foreach('test/fixtures/files/public-encrypted-voters.csv') do |row|
      content = upload.contents.new(sequence: sequence)
      row.each_with_index { |value, i| content[Content.field_index_to_sym(i)] = value }
      content.save!
      sequence += 1
    end

    file_type = FileType.create!(name: 'Final Votes', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 19)
    upload    = @public_election.uploads.new(file_type: file_type, status: :success, public: true, address: '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', checksum: 'checksum', retrieved_at: Time.current)
    upload.file.attach(io: File.open('test/fixtures/files/public-mixed-voters.csv'), filename: 'public-mixed-voters.csv', content_type: file_type.content_type)
    upload.save!

    sequence = 0
    CSV.foreach('test/fixtures/files/public-mixed-voters.csv') do |row|
      content = upload.contents.new(sequence: sequence)
      row.each_with_index { |value, i| content[Content.field_index_to_sym(i)] = value }
      content.save!
      sequence += 1
    end
  end

  test 'should not get status if missing election' do
    get verify_status_url
    assert_redirected_to root_path
  end

  test 'should not get status with private election' do
    get verify_status_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get status with public election not statusable' do
    @public_election.uploads.first.update!(public: false)
    refute @public_election.verification?

    get verify_status_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get status with missing beta' do
    get verify_status_url(election: @public_election.name)
    assert_response :success

    refute assigns(:voter_record)
    refute assigns(:vote_cast)
  end

  test 'should get status with public election but unknown beta' do
    assert @public_election.verification?

    beta = 1234567890

    get verify_status_url(election: @public_election.name, beta: beta)
    assert_response :accepted

    refute assigns(:voter_record)
    refute assigns(:vote_cast)
  end

  test 'should get status with public election with known beta but voting not complete' do
    assert @public_election.verification?

    csv  = CSV.parse(File.read('test/fixtures/files/public-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    file_type = FileType.find_by(name: 'Encrypted Votes with Tracker Numbers')
    file_type.uploads.destroy_all
    file_type.destroy

    get verify_status_url(election: @public_election.name, beta: beta)
    assert_response :success

    assert assigns(:voter_record)
    refute assigns(:vote_cast)
  end

  test 'should get status with public election with known beta with blank vote' do
    assert @public_election.verification?

    csv  = CSV.parse(File.read('test/fixtures/files/public-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    file_type = FileType.find_by(name: 'Encrypted Votes with Tracker Numbers')
    file_type.uploads.first.contents.where(field_00: beta).destroy_all

    get verify_status_url(election: @public_election.name, beta: beta)
    assert_response :success

    assert assigns(:voter_record)
    vote_cast = assigns(:vote_cast)
    assert !vote_cast
  end

  test 'should get status with public election with known beta with vote' do
    assert @public_election.verification?

    csv  = CSV.parse(File.read('test/fixtures/files/public-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_status_url(election: @public_election.name, beta: beta)
    assert_response :success

    assert assigns(:voter_record)
    vote_cast = assigns(:vote_cast)
    assert vote_cast
  end

  test 'should not get verify if missing election' do
    get verify_url
    assert_redirected_to root_path
  end

  test 'should not get verify with private election' do
    get verify_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get verify with public election not verifiable' do
    @public_election.uploads.first.update!(public: false)
    refute @public_election.verification?

    get verify_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get verify with missing parameters' do
    get verify_url(election: @public_election.name)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get verify with public election but unknown alpha and beta' do
    assert @public_election.verification?

    alpha = 1234567890
    beta  = 1234567890

    get verify_url(election: @public_election.name, alpha: alpha, beta: beta)
    assert_response :accepted

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get verify with public election but unknown tracker' do
    assert @public_election.verification?

    tracker = 11111111

    get verify_url(election: @public_election.name, tracker: tracker)
    assert_response :accepted

    refute assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should get verify with public election with known alpha and beta' do
    assert @public_election.verification?

    csv   = CSV.parse(File.read('test/fixtures/files/ers-encrypted-voters.csv'))
    alpha = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    csv  = CSV.parse(File.read('test/fixtures/files/ers-associated-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_url(election: @public_election.name, alpha: alpha, beta: beta)
    assert_response :success

    assert assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should get verify with public election with known tracker' do
    assert @public_election.verification?

    csv     = CSV.parse(File.read('test/fixtures/files/public-mixed-voters.csv'))
    tracker = csv[1][1].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_url(election: @public_election.name, tracker: tracker)
    assert_response :success

    assert assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should not get faq if missing election' do
    get verify_faq_url
    assert_redirected_to root_path
  end

  test 'should not get faq with private election' do
    get verify_faq_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get faq with public election not verifiable' do
    @public_election.uploads.first.update!(public: false)
    refute @public_election.verification?

    get verify_faq_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get faq with missing parameters' do
    get verify_faq_url(election: @public_election.name)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get faq with public election but unknown alpha and beta' do
    assert @public_election.verification?

    alpha = 1234567890
    beta  = 1234567890

    get verify_faq_url(election: @public_election.name, alpha: alpha, beta: beta)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get faq with public election but unknown tracker' do
    assert @public_election.verification?

    tracker = 11111111

    get verify_faq_url(election: @public_election.name, tracker: tracker)
    assert_response :success

    refute assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should get faq with public election with known alpha and beta' do
    assert @public_election.verification?

    csv   = CSV.parse(File.read('test/fixtures/files/ers-encrypted-voters.csv'))
    alpha = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    csv  = CSV.parse(File.read('test/fixtures/files/ers-associated-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_faq_url(election: @public_election.name, alpha: alpha, beta: beta)
    assert_response :success

    assert assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should get faq with public election with known tracker' do
    assert @public_election.verification?

    csv     = CSV.parse(File.read('test/fixtures/files/public-mixed-voters.csv'))
    tracker = csv[1][1].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_faq_url(election: @public_election.name, tracker: tracker)
    assert_response :success

    assert assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should not get report my vote if missing election' do
    get verify_report_my_vote_url
    assert_redirected_to root_path
  end

  test 'should not get report my vote with private election' do
    get verify_report_my_vote_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get report my vote with public election not verifiable' do
    @public_election.uploads.first.update!(public: false)
    refute @public_election.verification?

    get verify_report_my_vote_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not get report my vote with missing parameters' do
    get verify_report_my_vote_url(election: @public_election.name)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get report my vote with public election but unknown beta' do
    assert @public_election.verification?

    beta = 1234567890

    get verify_report_my_vote_url(election: @public_election.name, beta: beta)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get report my vote with public election but unknown tracker' do
    assert @public_election.verification?

    tracker = 11111111

    get verify_report_my_vote_url(election: @public_election.name, tracker: tracker)
    assert_response :success

    refute assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should get report my vote with public election with known beta' do
    assert @public_election.verification?

    csv  = CSV.parse(File.read('test/fixtures/files/ers-associated-voters.csv'))
    beta = csv[1][0].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_report_my_vote_url(election: @public_election.name, beta: beta)
    assert_response :success

    refute assigns(:vote_record)
    refute assigns(:voters_field_names)
  end

  test 'should get report my vote with public election with known tracker' do
    assert @public_election.verification?

    csv     = CSV.parse(File.read('test/fixtures/files/public-mixed-voters.csv'))
    tracker = csv[1][1].strip.gsub(/\A"|"\Z/, '').to_i

    get verify_report_my_vote_url(election: @public_election.name, tracker: tracker)
    assert_response :success

    assert assigns(:vote_record)
    assert assigns(:voters_field_names)
  end

  test 'should not post report if missing election' do
    post verify_send_report_url
    assert_redirected_to root_path
  end

  test 'should not post report with private election' do
    post verify_send_report_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not post report with public election not verifiable' do
    @public_election.uploads.first.update!(public: false)
    refute @public_election.verification?

    post verify_send_report_url(election: @private_election.name)
    assert_redirected_to root_path
  end

  test 'should not post report with missing parameters' do
    assert_no_enqueued_jobs(only: ActionMailer::DeliveryJob) do
      post verify_send_report_url(election: @public_election.name)
      assert_redirected_to root_path
    end

    assert_equal I18n.t('shared.messages.verify_not_report'), flash[:alert]
  end

  test 'should post report with public election and beta' do
    assert @public_election.verification?

    beta = 1234567890

    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post verify_send_report_url(election: @public_election.name, beta: beta)
      assert_redirected_to root_path
    end

    assert_equal I18n.t('shared.messages.verify_report'), flash[:notice]
  end

  test 'should post report with public election and tracker' do
    assert @public_election.verification?

    tracker = 11111111

    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post verify_send_report_url(election: @public_election.name, tracker: tracker)
      assert_redirected_to root_path
    end

    assert_equal I18n.t('shared.messages.verify_report'), flash[:notice]
  end
end
