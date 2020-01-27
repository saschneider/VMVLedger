#
# Services controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ServicesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user    = users(:user1)
    @service = services(:service)
  end

  test 'should not get edit if not logged in' do
    get edit_service_url(@service)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_service_url(@service)
    assert_response :success
  end

  test 'should update service if logged in' do
    sign_in @user

    patch service_url(@service), params: { service: @service.attributes }
    assert_redirected_to root_path
  end

  test 'should not update service if not logged in' do
    patch service_url(@service), params: { service: @service.attributes }
    assert_redirected_to new_user_session_path
  end
end