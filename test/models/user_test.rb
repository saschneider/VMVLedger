#
# User model tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'should not save if invalid' do
    user = User.new

    user.email            = nil
    user.forename         = nil
    user.surname          = nil
    user.terms_of_service = nil
    user.invitation       = nil

    user.save
    refute user.valid?
  end

  test 'should not save without invitation' do
    user = User.new

    user.email            = 'sid1@test.com'
    user.password         = 'Ab123456'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true

    user.save
    refute user.valid?
  end

  test 'should save and redeem invitation' do
    invitation = Invitation.create(email: 'sid1@test.com')
    refute invitation.redeemed

    user = User.new

    user.email            = 'sid1@test.com'
    user.password         = 'Ab123456'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true

    user.save
    assert user.valid?

    invitation.reload
    assert invitation.redeemed
  end

  test 'should not save without valid password' do
    Invitation.create(email: 'sid1@test.com')

    user = User.new

    user.email            = 'sid1@test.com'
    user.password         = 'password'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true

    user.save
    refute user.valid?
  end

  test 'should save with valid password' do
    Invitation.create(email: 'sid1@test.com')

    user = User.new

    user.email            = 'sid1@test.com'
    user.password         = 'Ab123456'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true

    user.save
    assert user.valid?
  end

  test 'should not save with duplicate email' do
    Invitation.create(email: 'sid1@test.com')

    user1                  = User.new
    user1.email            = 'sid1@test.com'
    user1.password         = 'Ab123456'
    user1.forename         = 'Sid'
    user1.surname          = 'Test'
    user1.terms_of_service = true
    user1.save
    assert user1.valid?

    user2                  = User.new
    user2.email            = 'sid1@test.com'
    user2.password         = 'Ab123456'
    user2.forename         = 'Sid'
    user2.surname          = 'Test'
    user2.terms_of_service = true
    user2.save
    refute user2.valid?
  end

  test 'should get fields' do
    Invitation.create(email: 'sid1@test.com')

    user                  = User.new
    user.email            = 'sid1@test.com'
    user.password         = 'Ab123456'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true
    user.role             = :administrator
    user.time_zone        = 'London'
    user.save
    assert user.valid?

    user.reload
    assert_equal 'sid1@test.com', user.email
    assert_equal 'Ab123456', user.password
    assert_equal 'Sid', user.forename
    assert_equal 'Test', user.surname
    assert_equal true, user.terms_of_service
    assert_equal :administrator, user.role.to_sym
    assert_equal 'London', user.time_zone
  end

  test 'should get fullname' do
    Invitation.create(email: 'sid1@test.com')

    user                  = User.new
    user.email            = 'sid1@test.com'
    user.password         = 'Ab123456'
    user.forename         = 'Sid'
    user.surname          = 'Test'
    user.terms_of_service = true
    user.save
    assert user.valid?

    assert_equal "#{user.forename} #{user.surname}", user.fullname
  end
end
