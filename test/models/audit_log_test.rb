#
# Audit log model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class AuditLogTest < ActiveSupport::TestCase

  setup do
    @user = users(:user1)
  end

  test 'should not save if invalid' do
    audit_log = AuditLog.new

    audit_log.action = nil
    audit_log.status = nil

    audit_log.save
    refute audit_log.valid?
  end

  test 'should save if valid' do
    audit_log = AuditLog.new

    audit_log.action = '/action'
    audit_log.status = 200

    audit_log.save
    assert audit_log.valid?
  end

  test 'should get fields' do
    audit_log        = AuditLog.new
    audit_log.user   = @user
    audit_log.action = '/action'
    audit_log.status = 200
    audit_log.save
    assert audit_log.valid?

    audit_log.reload
    assert_equal @user, audit_log.user
    assert_equal '/action', audit_log.action
    assert_equal 200, audit_log.status
  end
end
