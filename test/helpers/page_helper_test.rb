#
# Page helper tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class PageHelperTest < ActionView::TestCase

  test 'should return correct distance in time in hours and minutes' do
    assert_equal '00:00', distance_of_time_in_hours_and_minutes(nil, nil)
    assert_equal '00:00', distance_of_time_in_hours_and_minutes(Time.current, Time.current)
    assert_equal '00:01', distance_of_time_in_hours_and_minutes(Time.current, Time.current + 1.minute)
    assert_equal '01:00', distance_of_time_in_hours_and_minutes(Time.current, Time.current + 60.minutes)
    assert_equal '00:01', distance_of_time_in_hours_and_minutes(Time.current + 1.minute, Time.current)
    assert_equal '01:00', distance_of_time_in_hours_and_minutes(Time.current + 60.minutes, Time.current)
  end

  test 'should return link to not active' do
    def self.current_page?(_path)
      false
    end

    assert_equal '<a class="dropdown-item" href="/?locale=en">Name</a>', link_to_active('Name', root_path(locale: 'en'))
  end

  test 'should return link to active' do
    def self.current_page?(_path)
      true
    end

    assert_equal '<a class="dropdown-item active" href="/?locale=en">Name</a>', link_to_active('Name', root_path(locale: 'en'))
  end

  test 'should return link to list not active' do
    def self.current_page?(_path)
      false
    end

    assert_equal '<li class="nav-item"><a href="/?locale=en">Name</a></li>', link_to_list_active('Name', root_path(locale: 'en'))
  end

  test 'should return link to list active' do
    def self.current_page?(_path)
      true
    end

    assert_equal '<li class="nav-item active"><a href="/?locale=en">Name</a></li>', link_to_list_active('Name', root_path(locale: 'en'))
  end

  test 'should set page model' do
    model = User.new
    set_page_model(model)
    assert_equal @model, model
  end

  test 'should return default app title without specific title' do
    assert_equal I18n.t('app_title'), page_title
  end

  test 'should return default app title with specific nil title' do
    specific_title
    assert_equal I18n.t('app_title'), page_title
  end

  test 'should return default app title with specific title' do
    specific_title ['Title']
    assert_equal 'Title | ' + I18n.t('app_title'), page_title
  end

  test 'should return default app title with specific title and prefix' do
    specific_title %w(Prefix Title)
    assert_equal 'Prefix | ' + 'Title | ' + I18n.t('app_title'), page_title
  end

  test 'should return sortable column' do
    def self.sort_column
      :column
    end

    def self.sort_direction
      'asc'
    end

    def self.link_to title, options, html_options
      "#{title} #{options} #{html_options}"
    end

    assert_equal "title {:option=>true, :sort=>:column, :direction=>\"desc\"} {:class=>\"sort-current sort-asc\", :title=>\"Sort descending\"}", sortable(:column, 'title', option: true)
  end
end
