#
# Invitation model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class InvitationTest < ActiveSupport::TestCase

  test 'should not save if invalid' do
    invitation = Invitation.new

    invitation.email    = nil
    invitation.redeemed = nil

    invitation.save
    refute invitation.valid?
  end

  test 'should save if valid' do
    invitation = Invitation.new

    invitation.email = 'sid1@test.com'

    invitation.save
    assert invitation.valid?
  end

  test 'should not save with duplicate email' do
    invitation1       = Invitation.new
    invitation1.email = 'sid1@test.com'
    invitation1.save
    assert invitation1.valid?

    invitation2       = Invitation.new
    invitation2.email = 'sid1@test.com'
    invitation2.save
    refute invitation2.valid?
  end

  test 'should get fields' do
    invitation          = Invitation.new
    invitation.email    = 'sid1@test.com'
    invitation.redeemed = true
    invitation.save
    assert invitation.valid?

    invitation.reload
    assert_equal 'sid1@test.com', invitation.email
    assert_equal true, invitation.redeemed
  end
end
