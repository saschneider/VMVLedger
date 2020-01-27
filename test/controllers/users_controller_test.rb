#
# Users controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user1)
  end

  test 'should not get index if not logged in' do
    get users_url
    assert_redirected_to new_user_session_path
  end

  test 'should get index if logged in' do
    sign_in @user

    get users_url
    assert_response :success
  end

  test 'should not get edit if not logged in' do
    get edit_user_url(@user)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_user_url(@user)
    assert_response :success
  end

  test 'should not update user if not logged in' do
    patch user_url(@user), params: { user: @user.attributes }
    assert_redirected_to new_user_session_path
  end

  test 'should update user if logged in' do
    sign_in @user

    patch user_url(@user), params: { user: @user.attributes }
    assert_redirected_to users_url
  end

  test 'should not destroy user if not logged in' do
    assert_no_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to new_user_session_path
  end

  test 'should destroy user if logged in' do
    sign_in @user

    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
