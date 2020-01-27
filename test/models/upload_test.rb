#
# Upload model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class UploadTest < ActiveSupport::TestCase
  include QuorumTestHelper

  setup do
    @election             = elections(:public_election)
    @file_type_public     = file_types(:election_parameters)
    @file_type_not_public = file_types(:not_public)
  end

  test 'should not save if invalid' do
    upload = Upload.new

    upload.election  = nil
    upload.file_type = nil
    upload.status    = nil
    upload.public    = nil

    upload.save
    refute upload.valid?
  end

  test 'should not save if uploaded and no address or checksum' do
    upload = Upload.new

    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :success
    upload.public    = true

    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?

    upload.save
    refute upload.valid?
  end

  test 'should save if valid' do
    upload = Upload.new

    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :pending
    upload.public    = true

    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?

    upload.save
    assert upload.valid?
  end

  test 'should not set public if file type not public' do
    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_not_public
    upload.status    = :success
    upload.public    = true
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    refute upload.valid?
  end

  test 'should not download from blockchain as no url' do
    Service.get_service.update!(nodes: nil)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    assert_nothing_raised do
      assert_nil upload.download_from_blockchain!
    end
  end

  test 'should not download from blockchain as no address' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    assert_nothing_raised do
      assert_nil upload.download_from_blockchain!
    end
  end

  test 'should not download from blockchain as fail get contract' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    stub_get_contract(self, url, true)

    e = assert_raises QuorumHelper::QuorumError do
      assert_nil upload.download_from_blockchain!
    end

    assert e.message.start_with? I18n.t('quorum_helper.get_contract_failed', url: url, message: '')
  end

  test 'should not download from blockchain as fail get' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    stub_get_contract(self, url)
    stub_call_contract(self, url, [], true)

    e = assert_raises QuorumHelper::QuorumError do
      assert_nil upload.download_from_blockchain!
    end

    assert e.message.start_with? I18n.t('quorum_file_helper.file_wrapper.call_failed', message: '')
  end

  test 'should download from blockchain' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    lines           = upload.file.download.lines
    number_of_lines = lines.size

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum        = digest.base64digest
    upload.checksum = checksum
    upload.save

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{filename},#{content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    assert_nothing_raised do
      assert_not_nil upload.download_from_blockchain!
    end
  end

  test 'should not update content as not convertable' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    @file_type_public.update!(convert_to_content: false)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    assert_nothing_raised do
      assert_no_difference 'Content.count' do
        assert upload.update_content!
      end
    end

    upload.reload
    assert_nil upload.retrieved_at
  end

  test 'should not update content as cannot download' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    stub_get_contract(self, url, true)

    e = assert_raises QuorumHelper::QuorumError do
      assert_no_difference 'Content.count' do
        refute upload.update_content!
      end
    end

    assert e.message.start_with? I18n.t('quorum_helper.get_contract_failed', url: url, message: '')

    upload.reload
    assert_nil upload.retrieved_at
  end

  test 'should update content and get field names and indices' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    filename     = 'public-election-params.csv'
    content_type = 'text/csv'

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: filename, content_type: content_type)
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    lines           = upload.file.download.lines
    number_of_lines = lines.size

    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    checksum        = digest.base64digest
    upload.checksum = checksum
    upload.save

    encoder = Ethereum::Encoder.new
    results = ['0x' + encoder.encode_string("#{filename},#{content_type},#{checksum}", nil).join('')]

    stub_get_contract(self, url)
    stub_call_contract(self, url, results)

    assert_nothing_raised do
      assert_difference 'Content.count', number_of_lines do
        assert upload.update_content!
      end
    end

    upload.reload
    assert_equal number_of_lines, upload.contents.size
    assert_not_nil upload.retrieved_at

    field_names = upload.get_field_names
    assert_not_empty field_names

    assert_not_nil upload.field_name_to_sym('p')
  end

  test 'should not get field names as no content' do
    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :success
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.checksum  = 'checksum'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    assert_equal 0, upload.contents.count
    assert_nil upload.get_field_names
  end

  test 'should not upload to blockchain as no url' do
    Service.get_service.update!(nodes: nil)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    assert_nothing_raised do
      assert_nil upload.upload_to_blockchain!
    end

    upload.reload
    assert_nil upload.address
  end

  test 'should not upload to blockchain as fail create contract' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, upload.address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT, [true, true, true])

    e = assert_raises QuorumHelper::QuorumError do
      assert_nil upload.upload_to_blockchain!
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should not upload to blockchain as fail upload to contract' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    number_of_lines = upload.file.download.lines.size

    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, upload.address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT)
    stub_transact_contract(self, url, upload.address, [true, true])
    stub_call_contract(self, url, [0.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), (number_of_lines + 1).to_s(16)])

    e = assert_raises QuorumHelper::QuorumError do
      assert_nil upload.upload_to_blockchain!
    end

    assert e.message.start_with? I18n.t('quorum_helper.create_contract_failed', url: url, message: '')
  end

  test 'should upload to blockchain' do
    url = 'http://localhost:22000'
    Service.get_service.update!(nodes: url)

    upload           = Upload.new
    upload.election  = @election
    upload.file_type = @file_type_public
    upload.status    = :creating
    upload.public    = true
    upload.address   = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    number_of_lines = upload.file.download.lines.size

    stub_create_contract(self, url, QuorumFileHelper::CONTRACT_FILE_CODE, upload.address, QuorumFileHelper::CONTRACT_GAS_PRICE, QuorumFileHelper::CONTRACT_GAS_LIMIT)
    stub_transact_contract(self, url, upload.address)
    stub_call_contract(self, url, [0.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), number_of_lines.to_s(16), (number_of_lines + 1).to_s(16)])

    assert_nothing_raised do
      assert_not_nil upload.upload_to_blockchain!
    end

    upload.reload
    assert_not_nil upload.address
  end

  test 'should get fields' do
    upload              = Upload.new
    upload.election     = @election
    upload.file_type    = @file_type_public
    upload.status       = :success
    upload.public       = true
    upload.address      = '0xab4cb6367adcbb464eede7f397c2931a3ddf5937'
    upload.checksum     = 'checksum'
    upload.retrieved_at = Time.current
    upload.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    assert upload.file.attached?
    upload.save
    assert upload.valid?

    upload.reload
    assert_equal @election, upload.election
    assert_equal @file_type_public, upload.file_type
    assert upload.success?
    assert upload.public?
    assert_not_nil upload.retrieved_at
    assert_equal '0xab4cb6367adcbb464eede7f397c2931a3ddf5937', upload.address
    assert_equal 'checksum', upload.checksum
  end
end
