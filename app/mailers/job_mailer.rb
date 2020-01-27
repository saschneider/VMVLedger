#
# Job mailer class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class JobMailer < ApplicationMailer

  #
  # Sends an error to all administrators.
  #
  # @param error The error to be sent.
  # @param type The type of error.
  #
  def error(error, type = nil)
    emails = User.where(role: :administrator).pluck(:email)
    @error = error

    mail(from:    I18n.t('no_reply_email'),
         to:      emails,
         subject: I18n.t('job_mailer.error_subject', app_title: I18n.t('app_title'), type: type))
  end

end