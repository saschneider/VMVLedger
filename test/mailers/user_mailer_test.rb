#
# User mailer tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'action_mailer'

class UserMailerTest < ActionMailer::TestCase

  test 'invitation' do
    email  = 'sid@test.com'
    mailer = UserMailer.invitation(email)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [email], mailer.to
    assert_equal I18n.t('user_mailer.invitation_subject', app_title: I18n.t('app_title')), mailer.subject

    assert_equal 2, mailer.body.parts.count
    mailer.body.parts.each do |part|
      unless part.content_type.start_with?('image/png')
        assert part.to_s.include? 'invited'
      end
    end
  end

  test 'report with service verify email' do
    email = 'test@test.com'
    Service.get_service.update(verify_email: email)

    election = 'Test Election'
    beta     = 1234567890
    tracker  = 567890
    mailer   = UserMailer.report(election, beta, tracker)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [email], mailer.to
    assert_equal [I18n.t('company_email')], mailer.cc
    assert_equal I18n.t('user_mailer.report_subject', app_title: I18n.t('app_title')), mailer.subject

    assert_equal 2, mailer.body.parts.count
    mailer.body.parts.each do |part|
      unless part.content_type.start_with?('image/png')
        assert part.to_s.include? 'voter'
      end
    end
  end

  test 'report without service verify email' do
    Service.get_service.update(verify_email: nil)

    election = 'Test Election'
    beta     = 1234567890
    tracker  = 567890
    reason   = 'Reason'
    mailer   = UserMailer.report(election, beta, tracker, reason)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    assert_equal [I18n.t('company_email')], mailer.to
    assert_equal [I18n.t('company_email')], mailer.cc
    assert_equal I18n.t('user_mailer.report_subject', app_title: I18n.t('app_title')), mailer.subject

    assert_equal 2, mailer.body.parts.count
    mailer.body.parts.each do |part|
      unless part.content_type.start_with?('image/png')
        assert part.to_s.include? 'voter'
      end
    end
  end
end