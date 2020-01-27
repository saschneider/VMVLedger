#
# Home controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user1)
  end

  test 'should get about if not logged in' do
    get about_url
    assert_response :success
  end

  test 'should get about if logged in' do
    sign_in @user

    get about_url
    assert_response :success
  end

  test 'should get documents if not logged in' do
    get documents_url
    assert_response :success
  end

  test 'should get documents if logged in' do
    sign_in @user

    get documents_url
    assert_response :success
  end

  test 'should get challenge' do
    name = 'challenge'
    path = Rails.public_path.join('.well-known', 'acme-challenge', name)

    begin
      content = 'Response'
      File.open(path, 'w') { |file| file.write(content) }

      get challenge_url(file: name)
      assert_response :success
      assert_equal content, response.body
    ensure
      File.delete(path)
    end
  end

  test 'should get home if not logged in' do
    get home_url
    assert_response :success
  end

  test 'should get home if logged in' do
    sign_in @user

    get home_url
    assert_response :success
  end

  test 'should get privacy if not logged in' do
    get privacy_url
    assert_response :success
  end

  test 'should get privacy if logged in' do
    sign_in @user

    get privacy_url
    assert_response :success
  end

  test 'should get privacy' do
    get privacy_url
    assert_response :success
  end

  test 'should get root redirect' do
    get root_url
    assert_redirected_to home_path
  end

  test 'should get verifiable if not logged in' do
    get verifiable_url
    assert_response :success
  end

  test 'should get verifiable if logged in' do
    sign_in @user

    get verifiable_url
    assert_response :success
  end
end
