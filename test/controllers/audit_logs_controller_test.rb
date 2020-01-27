#
# Audit logs controller test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class AuditLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user1)
  end

  test 'should not get index if not logged in' do
    assert_difference 'AuditLog.count', 1 do
      get audit_logs_url
      assert_redirected_to new_user_session_path
    end

    assert AuditLog.last.user.nil?
  end

  test 'should get index if logged in' do
    sign_in @user

    assert_difference 'AuditLog.count', 1 do
      get audit_logs_url
      assert_response :success
    end

    refute AuditLog.last.user.nil?
  end
end
