#
# Form helper tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'minitest/mock'

class FormHelperTest < ActionView::TestCase

  test 'should return field with title' do
    object   = User.new
    field    = :email
    required = true
    options  = { test: 'test' }

    form = Minitest::Mock.new
    form.expect :object, object
    form.expect :object, object
    form.expect :'required_attribute?', required, [object, field]
    form.expect :method, '', [field, options.merge(title: I18n.t("activerecord.titles.user.#{field}"), required: required, label_class: 'required')]

    assert_not_nil form_field(form, :method, field, options)
  end

  test 'should return field without title' do
    object   = User.new
    field    = :rubbish
    required = true
    options  = { test: 'test' }

    form = Minitest::Mock.new
    form.expect :object, object
    form.expect :object, object
    form.expect :'required_attribute?', true, [object, field]
    form.expect :method, '', [field, options.merge(required: required, label_class: 'required')]

    assert_not_nil form_field(form, :method, field, options)
  end

  test 'should return field not required' do
    object  = User.new
    field   = :rubbish
    options = { test: 'test' }

    form = Minitest::Mock.new
    form.expect :object, object
    form.expect :object, object
    form.expect :'required_attribute?', false, [object, field]
    form.expect :method, '', [field, options]

    assert_not_nil form_field(form, :method, field, options)
  end

  test 'should return field select' do
    object  = User.new
    field   = :rubbish
    options = { select_options: [['Apple', 1], ['Grape', 2]] }

    form = Minitest::Mock.new
    form.expect :object, object
    form.expect :object, object
    form.expect :'required_attribute?', false, [object, field]
    form.expect :select, '', [field, options[:select_options], {}]

    assert_not_nil form_field(form, :select, field, options)
  end
end
