#
# Custom Devise mailer tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'action_mailer'

class CustomDeviseMailerTest < ActionMailer::TestCase

  test 'confirmation instructions' do
    user   = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    mailer = CustomDeviseMailer.confirmation_instructions(user, 'faketoken')

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [user.email], mailer.to
  end

  test 'reset password instructions' do
    user   = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    mailer = CustomDeviseMailer.reset_password_instructions(user, 'faketoken')

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [user.email], mailer.to
  end

  test 'unlock instructions' do
    user   = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    mailer = CustomDeviseMailer.unlock_instructions(user, 'faketoken')

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [user.email], mailer.to
  end

  test 'email changed' do
    user   = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    mailer = CustomDeviseMailer.email_changed(user)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [user.email], mailer.to
  end

  test 'password change' do
    user   = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    mailer = CustomDeviseMailer.password_change(user)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [user.email], mailer.to
  end
end