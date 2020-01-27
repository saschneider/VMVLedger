#
# User mailer class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UserMailer < ApplicationMailer

  #
  # Sends an invitation to a new user.
  #
  # @param email The email for the person being invited.
  #
  def invitation(email)
    mail(from:    I18n.t('no_reply_email'),
         to:      email,
         subject: I18n.t('user_mailer.invitation_subject', app_title: I18n.t('app_title')))
  end

  #
  # Sends a verification report email to the appropriate contact email address.
  #
  # @param election The name of the election.
  # @param beta The beta parameter associated with the voter's vote.
  # @param tracker The tracker number associated with the voter's vote.
  # @param reason An optional reason for the report.
  #
  def report(election, beta, tracker, reason = nil)
    @election = election
    @beta     = beta
    @tracker  = tracker
    @reason   = reason

    # Send the email to the configured email address, if it exists.
    email = Service.get_service.verify_email
    email = I18n.t('company_email') if email.blank?

    mail(from:    I18n.t('no_reply_email'),
         to:      email,
         cc:      I18n.t('company_email'),
         subject: I18n.t('user_mailer.report_subject', app_title: I18n.t('app_title')))
  end
end