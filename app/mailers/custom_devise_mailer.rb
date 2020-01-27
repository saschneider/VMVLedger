#
# Custom Devise mailer class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CustomDeviseMailer < Devise::Mailer

  # Give access to all helpers defined within `application_helper`.
  helper :application

  # Give access to `confirmation_url`, etc.
  include Devise::Controllers::UrlHelpers

  # Make sure that the mailer uses the devise views.
  default template_path: 'devise/mailer'

  #
  # Custom Devise email.
  #
  # @param record The associated user record.
  # @param token The associated token.
  # @param opts Options.
  #
  def confirmation_instructions(record, token, opts = {})
    super(record, token, opts.merge(subject: I18n.t("devise.mailer.#{__method__}.subject", app_title: I18n.t('app_title'))))
  end

  #
  # Custom Devise email.
  #
  # @param record The associated user record.
  # @param token The associated token.
  # @param opts Options.
  #
  def reset_password_instructions(record, token, opts = {})
    super(record, token, opts.merge(subject: I18n.t("devise.mailer.#{__method__}.subject", app_title: I18n.t('app_title'))))
  end

  #
  # Custom Devise email.
  #
  # @param record The associated user record.
  # @param token The associated token.
  # @param opts Options.
  #
  def unlock_instructions(record, token, opts = {})
    super(record, token, opts.merge(subject: I18n.t("devise.mailer.#{__method__}.subject", app_title: I18n.t('app_title'))))
  end

  #
  # Custom Devise email.
  #
  # @param record The associated user record.
  # @param opts Options.
  #
  def email_changed(record, opts = {})
    super(record, opts.merge(subject: I18n.t("devise.mailer.#{__method__}.subject", app_title: I18n.t('app_title'))))
  end

  #
  # Custom Devise email.
  #
  # @param record The associated user record.
  # @param opts Options.
  #
  def password_change(record, opts = {})
    super(record, opts.merge(subject: I18n.t("devise.mailer.#{__method__}.subject", app_title: I18n.t('app_title'))))
  end

end