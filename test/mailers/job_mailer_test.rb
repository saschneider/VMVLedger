#
# Job mailer tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'action_mailer'

class JobMailerTest < ActionMailer::TestCase

  test 'error' do
    error = StandardError.new('message')
    error.set_backtrace(caller)
    type   = 'Type'
    mailer = JobMailer.error(error, type)

    assert_emails 1 do
      mailer.deliver_now
    end

    assert_equal [I18n.t('no_reply_email')], [mailer.from].flatten
    emails = User.where(role: :administrator).pluck(:email)
    assert_equal emails, mailer.to
    assert_equal I18n.t('job_mailer.error_subject', app_title: I18n.t('app_title'), type: type), mailer.subject

    assert_equal 2, mailer.body.parts.count
    mailer.body.parts.each do |part|
      unless part.content_type.start_with?('image/png')
        assert part.to_s.include? 'error'
      end
    end
  end

end