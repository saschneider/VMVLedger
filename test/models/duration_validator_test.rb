#
# Duration validator tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class DurationValidatorTest < ActiveSupport::TestCase

  test 'should not validate duration' do
    validator = DurationValidator.new({ attributes: :retrieve_interval })

    object = Service.new(retrieve_interval: 'rubbish')
    validator.validate_each(object, :retrieve_interval, 'rubbish')

    assert_equal [I18n.t('activerecord.validators.not_a_duration')], object.errors[:retrieve_interval]
  end

  test 'should validate duration' do
    validator = DurationValidator.new({ attributes: :retrieve_interval })

    object = Service.new(retrieve_interval: 'rubbish')
    validator.validate_each(object, :retrieve_interval, 12.weeks.iso8601)

    assert_equal [], object.errors[:retrieve_interval]
  end

end
