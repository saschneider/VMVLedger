#
# Election model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ElectionTest < ActiveSupport::TestCase

  test 'should not save if invalid' do
    election = Election.new

    election.name       = nil
    election.public     = nil
    election.survey_url = 'rubbish'

    election.save
    refute election.valid?
  end

  test 'should save if valid' do
    election = Election.new

    election.name   = 'Test Election'
    election.public = true

    election.save
    assert election.valid?
  end

  test 'should not save with duplicate name' do
    election1      = Election.new
    election1.name = 'Test Election'
    election1.save
    assert election1.valid?

    election2      = Election.new
    election2.name = 'Test Election'
    election2.save
    refute election2.valid?
  end

  test 'should not get verification as not all needed files available' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_verify  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.public       = true
    upload1.retrieved_at = Time.current
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_verify  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    election.reload
    refute election.verification?
  end

  test 'should not get verification as not all needed public files public' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_verify  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = Time.current
    upload1.public       = false
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_verify  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    refute election.verification?
  end

  test 'should not get verification as not all needed public files retrieved' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_verify  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = nil
    upload1.public       = true
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_verify  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    refute election.verification?
  end

  test 'should get verification as all needed files available' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_verify  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = Time.current
    upload1.public       = true
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_verify  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    assert election.verification?
  end

  test 'should not get status as no needed files available' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_status  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_status  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    election.reload
    refute election.status?
  end

  test 'should not get status as not all needed public files public' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_status  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = Time.current
    upload1.public       = false
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_status  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    refute election.status?
  end

  test 'should not get status as not all needed public files retrieved' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_status  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = nil
    upload1.public       = true
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_status  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    refute election.status?
  end

  test 'should get status as one file available' do
    election        = Election.new
    election.name   = 'Test Election'
    election.public = true
    election.save
    assert election.valid?

    election.uploads.destroy_all
    FileType.destroy_all

    file_type1                    = FileType.new
    file_type1.name               = 'Public'
    file_type1.action             = :no_action
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_status  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save!

    upload1              = Upload.new
    upload1.election     = election
    upload1.file_type    = file_type1
    upload1.status       = :success
    upload1.address      = '0x123456789'
    upload1.checksum     = 'checksum'
    upload1.retrieved_at = Time.current
    upload1.public       = true
    upload1.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload1.save!

    file_type2                    = FileType.new
    file_type2.name               = 'Private'
    file_type2.action             = :no_action
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_status  = true
    file_type2.sequence           = 1
    file_type2.public             = false
    file_type2.save!

    upload2           = Upload.new
    upload2.election  = election
    upload2.file_type = file_type2
    upload2.status    = :success
    upload2.address   = '0x123456789'
    upload2.checksum  = 'checksum'
    upload2.public    = false
    upload2.file.attach(io: File.open('test/fixtures/files/public-election-params.csv'), filename: 'public-election-params.csv', content_type: 'text/csv')
    upload2.save!

    election.reload
    assert election.status?
  end

  test 'should get fields' do
    election             = Election.new
    election.name        = 'Test Election'
    election.public      = true
    election.survey_url  = 'http://localhost:3000'
    election.description = 'Description'
    election.save
    assert election.valid?

    election.reload
    assert_equal 'Test Election', election.name
    assert election.public?
    assert_equal 'http://localhost:3000', election.survey_url
    assert_equal 'Description', election.description
  end
end
