#
# File types controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class FileTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user              = users(:user1)
    @file_type         = file_types(:election_parameters)
    @file_type_destroy = file_types(:election_keys)
    @create_file_type  = FileType.new(name: 'New File Type', content_type: 'text/csv', sequence: 1)
  end

  test 'should not get index if not logged in' do
    get file_types_url
    assert_redirected_to new_user_session_path
  end

  test 'should get index if logged in' do
    sign_in @user

    get file_types_url
    assert_response :success
  end

  test 'should not show file type if not logged in' do
    get file_type_url(@file_type)
    assert_redirected_to new_user_session_path
  end

  test 'should show file type if logged in' do
    sign_in @user

    get file_type_url(@file_type)
    assert_response :success
  end

  test 'should not get new if not logged in' do
    get new_file_type_url
    assert_redirected_to new_user_session_path
  end

  test 'should get new if logged in' do
    sign_in @user

    get new_file_type_url
    assert_response :success
  end

  test 'should not create file type if not logged in' do
    assert_no_difference('FileType.count') do
      post file_types_url, params: { file_type: @create_file_type.attributes }
    end

    assert_redirected_to new_user_session_path
  end

  test 'should create file type if logged in' do
    sign_in @user

    assert_difference('FileType.count') do
      post file_types_url, params: { file_type: @create_file_type.attributes }
    end

    assert_redirected_to file_types_url
  end

  test 'should not get edit if not logged in' do
    get edit_file_type_url(@file_type)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_file_type_url(@file_type)
    assert_response :success
  end

  test 'should not update file type if not logged in' do
    patch file_type_url(@file_type), params: { file_type: @file_type.attributes }
    assert_redirected_to new_user_session_path
  end

  test 'should update file type if logged in' do
    sign_in @user

    patch file_type_url(@file_type), params: { file_type: @file_type.attributes }
    assert_redirected_to file_types_url
  end

  test 'should not destroy file type if not logged in' do
    assert_no_difference('FileType.count', -1) do
      delete file_type_url(@file_type)
    end

    assert_redirected_to new_user_session_path
  end

  test 'should destroy file type if logged in and no uploads' do
    sign_in @user

    assert_difference('FileType.count', -1) do
      delete file_type_url(@file_type_destroy)
    end

    assert_redirected_to file_types_url
  end

  test 'should not destroy file type if logged in but has uploads' do
    sign_in @user

    assert_no_difference('FileType.count') do
      delete file_type_url(@file_type)
    end

    assert_redirected_to file_types_url
  end
end
