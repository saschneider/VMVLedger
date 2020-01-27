#
# Invitations controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user              = users(:user1)
    @invitation        = invitations(:invitation2)
    @create_invitation = Invitation.new(email: 'new@test.com')
  end

  test 'should not get index if not logged in' do
    get invitations_url
    assert_redirected_to new_user_session_path
  end

  test 'should get index if logged in' do
    sign_in @user

    get invitations_url
    assert_response :success
  end

  test 'should not get new if not logged in' do
    get new_invitation_url
    assert_redirected_to new_user_session_path
  end

  test 'should get new if logged in' do
    sign_in @user

    get new_invitation_url
    assert_response :success
  end

  test 'should not create invitation if not logged in' do
    assert_no_difference('Invitation.count') do
      post invitations_url, params: { invitation: @create_invitation.attributes }
    end

    assert_redirected_to new_user_session_path
  end

  test 'should create invitation if logged in' do
    sign_in @user

    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      assert_difference('Invitation.count') do
        post invitations_url, params: { invitation: @create_invitation.attributes }
      end

      assert_redirected_to invitations_url
    end
  end

  test 'should not get edit if not logged in' do
    get edit_invitation_url(@invitation)
    assert_redirected_to new_user_session_path
  end

  test 'should get edit if logged in' do
    sign_in @user

    get edit_invitation_url(@invitation)
    assert_response :success
  end

  test 'should not update invitation if not logged in' do
    patch invitation_url(@invitation), params: { invitation: @invitation.attributes }
    assert_redirected_to new_user_session_path
  end

  test 'should update invitation if logged in but not new email' do
    sign_in @user

    assert_no_enqueued_jobs do
      patch invitation_url(@invitation), params: { invitation: @invitation.attributes }
      assert_redirected_to invitations_url
    end
  end

  test 'should update invitation if logged in with new email' do
    sign_in @user

    @invitation.email = "#{@invitation.email}.au"

    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      patch invitation_url(@invitation), params: { invitation: @invitation.attributes }
      assert_redirected_to invitations_url
    end
  end

  test 'should not destroy invitation if not logged in' do
    assert_no_difference('Invitation.count', -1) do
      delete invitation_url(@invitation)
    end

    assert_redirected_to new_user_session_path
  end

  test 'should destroy invitation if logged in' do
    sign_in @user

    assert_difference('Invitation.count', -1) do
      delete invitation_url(@invitation)
    end

    assert_redirected_to invitations_url
  end
end
