#
# Job mailer previews class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class JobMailerPreview < ActionMailer::Preview

  def error
    error = StandardError.new('message')
    error.set_backtrace(caller)
    JobMailer.error(error, 'Type')
  end
end