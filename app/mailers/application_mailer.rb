#
# Application mailer class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ApplicationMailer < ActionMailer::Base
  default from: I18n.t('no_reply_email')
  layout 'mailer'
end
