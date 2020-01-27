#
# Content model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ContentTest < ActiveSupport::TestCase

  setup do
    @upload = uploads(:election_parameters_with_content)
  end

  test 'should not save if invalid' do
    content = Content.new

    content.upload   = nil
    content.sequence = nil

    content.save
    refute content.valid?
  end

  test 'should save if valid' do
    content = Content.new

    content.upload   = @upload
    content.sequence = 0
    content.field_00 = 'Value'

    content.save
    assert content.valid?
  end

  test 'should not save with duplicate name' do
    content1          = Content.new
    content1.upload   = @upload
    content1.sequence = 0
    content1.field_00 = 'Value 1'
    content1.save
    assert content1.valid?

    content2          = Content.new
    content2.upload   = @upload
    content2.sequence = 0
    content2.field_00 = 'Value 2'
    content2.save
    refute content2.valid?
  end

  test 'should get field index to sym' do
    assert_equal :field_00, Content.field_index_to_sym(0)
    assert_equal :field_19, Content.field_index_to_sym(19)
  end

  test 'should get fields' do
    content          = Content.new
    content.upload   = @upload
    content.sequence = 1
    content.field_00 = '0'
    content.field_01 = '1'
    content.field_02 = '2'
    content.field_03 = '3'
    content.field_04 = '4'
    content.field_05 = '5'
    content.field_06 = '6'
    content.field_07 = '7'
    content.field_08 = '8'
    content.field_09 = '9'
    content.field_10 = '10'
    content.field_11 = '11'
    content.field_12 = '12'
    content.field_13 = '13'
    content.field_14 = '14'
    content.field_15 = '15'
    content.field_16 = '16'
    content.field_17 = '17'
    content.field_18 = '18'
    content.field_19 = '19'
    content.save
    assert content.valid?

    content.reload
    assert_equal @upload, content.upload
    assert_equal 1, content.sequence
    assert_equal '0', content.field_00
    assert_equal '1', content.field_01
    assert_equal '2', content.field_02
    assert_equal '3', content.field_03
    assert_equal '4', content.field_04
    assert_equal '5', content.field_05
    assert_equal '6', content.field_06
    assert_equal '7', content.field_07
    assert_equal '8', content.field_08
    assert_equal '9', content.field_09
    assert_equal '10', content.field_10
    assert_equal '11', content.field_11
    assert_equal '12', content.field_12
    assert_equal '13', content.field_13
    assert_equal '14', content.field_14
    assert_equal '15', content.field_15
    assert_equal '16', content.field_16
    assert_equal '17', content.field_17
    assert_equal '18', content.field_18
    assert_equal '19', content.field_19
  end
end
