#
# File type model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class FileTypeTest < ActiveSupport::TestCase

  test 'should not save if invalid' do
    file_type = FileType.new

    file_type.name               = nil
    file_type.action             = nil
    file_type.stage              = nil
    file_type.content_type       = nil
    file_type.convert_to_content = nil
    file_type.needed_for_verify  = nil
    file_type.needed_for_status  = nil
    file_type.sequence           = nil
    file_type.public             = nil

    file_type.save
    refute file_type.valid?
  end

  test 'should save if valid' do
    file_type = FileType.new

    file_type.name               = 'Test File Type'
    file_type.action             = :no_action
    file_type.stage              = :no_stage
    file_type.content_type       = 'text/csv'
    file_type.convert_to_content = true
    file_type.needed_for_verify  = true
    file_type.needed_for_status  = true
    file_type.sequence           = 1
    file_type.public             = true

    file_type.save
    assert file_type.valid?
  end

  test 'should not save with duplicate name' do
    file_type1                    = FileType.new
    file_type1.name               = 'Test File Type'
    file_type1.action             = :no_action
    file_type1.stage              = :no_stage
    file_type1.content_type       = 'text/csv'
    file_type1.convert_to_content = true
    file_type1.needed_for_verify  = true
    file_type1.needed_for_status  = true
    file_type1.sequence           = 1
    file_type1.public             = true
    file_type1.save
    assert file_type1.valid?

    file_type2                    = FileType.new
    file_type2.name               = 'Test File Type'
    file_type2.action             = :no_action
    file_type2.stage              = :no_stage
    file_type2.content_type       = 'text/csv'
    file_type2.convert_to_content = true
    file_type2.needed_for_verify  = true
    file_type2.needed_for_status  = true
    file_type2.sequence           = 1
    file_type2.public             = true
    file_type2.save
    refute file_type2.valid?
  end

  test 'should get fields' do
    file_type                     = FileType.new
    file_type.name                = 'Test File Type'
    file_type.description         = 'Description'
    file_type.long_description    = 'Long description'
    file_type.content_description = 'Content description'
    file_type.action              = :no_action
    file_type.stage               = :no_stage
    file_type.content_type        = 'text/csv'
    file_type.hint                = 'file.csv'
    file_type.convert_to_content  = true
    file_type.needed_for_verify   = true
    file_type.needed_for_status   = true
    file_type.sequence            = 1
    file_type.public              = true
    file_type.save
    assert file_type.valid?

    file_type.reload
    assert_equal 'Test File Type', file_type.name
    assert_equal 'Description', file_type.description
    assert_equal 'Long description', file_type.long_description
    assert_equal 'Content description', file_type.content_description
    assert file_type.no_action?
    assert file_type.no_stage?
    assert_equal 'text/csv', file_type.content_type
    assert_equal 'file.csv', file_type.hint
    assert file_type.convert_to_content?
    assert file_type.needed_for_verify?
    assert file_type.needed_for_status?
    assert_equal 1, file_type.sequence
    assert file_type.public?
  end
end
