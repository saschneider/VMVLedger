#
# URL validator tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase

  test 'should not validate URL' do
    validator = UrlValidator.new({ attributes: :survey_url })

    object = Election.new(survey_url: 'rubbish')
    validator.validate_each(object, :survey_url, 'rubbish')

    assert_equal [I18n.t('activerecord.validators.not_a_url')], object.errors[:survey_url]
  end

  test 'should validate duration' do
    validator = UrlValidator.new({ attributes: :survey_url })

    object = Election.new(survey_url: 'rubbish')
    validator.validate_each(object, :survey_url, 'https://www.example.com')

    assert_equal [], object.errors[:survey_url]
  end

end
