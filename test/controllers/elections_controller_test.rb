#
# Elections controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class ElectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user             = users(:user1)
    @public_election  = elections(:public_election)
    @private_election = elections(:private_election)
    @create_election  = Election.new(name: 'New Election')
  end

  test 'should get index if not logged in for all public elections' do
    get elections_url
    assert_response :success

    elections = assigns(:elections)
    elections.each do |election|
      assert election.public?
    end
  end

  test 'should not get index if not logged in for and ui disabled' do
    Service.get_service.update!(ui_enabled: false)

    get elections_url
    assert_redirected_to root_path
  end

  test 'should get index if logged in for all elections' do
    sign_in @user

    get elections_url
    assert_response :success

    elections = assigns(:elections)
    elections.each do |election|
      assert election.public? || !election.public?
    end
  end

  test 'should show election if not logged in if public election' do
    get election_url(@public_election)
    assert_response :success

    uploads = assigns(:uploads)
    uploads.each do |upload|
      assert upload.public?
    end
  end

  test 'should not show election if not logged in and ui disabled' do
    Service.get_service.update!(ui_enabled: false)

    get election_url(@public_election)
    assert_redirected_to root_path
  end

  test 'should not show election if not logged in if private election' do
    get election_url(@private_election)
    assert_redirected_to root_path
  end

  test 'should show election if logged in if private election' do
    sign_in @user

    get election_url(@private_election)
    assert_response :success
  end

  test 'should not get new if not logged in' do
    get new_election_url
    assert_redirected_to new_user_session_path
  end

  test 'should get new if logged in' do
    sign_in @user

    get new_election_url
    assert_response :success
  end

  test 'should not create election if not logged in' do
    assert_no_difference('Election.count') do
      post elections_url, params: { election: @create_election.attributes }
    end

    assert_redirected_to new_user_session_path
  end

  test 'should create election if logged in' do
    sign_in @user

    assert_difference('Election.count') do
      post elections_url, params: { election: @create_election.attributes }
    end

    assert_redirected_to elections_url
  end

  test 'should not get edit if not logged in' do
    get edit_election_url(@public_election)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_election_url(@public_election)
    assert_response :success
  end

  test 'should not update election if not logged in' do
    patch election_url(@public_election), params: { election: @public_election.attributes }
    assert_redirected_to new_user_session_path
  end

  test 'should update election if logged in' do
    sign_in @user

    patch election_url(@public_election), params: { election: @public_election.attributes }
    assert_redirected_to elections_url
  end

  test 'should not destroy election if not logged in' do
    assert_no_difference('Election.count', -1) do
      delete election_url(@public_election)
    end

    assert_redirected_to new_user_session_path
  end

  test 'should destroy election if logged in and no uploads' do
    sign_in @user

    assert_difference('Election.count', -1) do
      delete election_url(@private_election)
    end

    assert_redirected_to elections_url
  end

  test 'should not destroy election if logged in but has uploads' do
    sign_in @user

    assert_no_difference('Election.count') do
      delete election_url(@public_election)
    end

    assert_redirected_to elections_url
  end
end
