#
# User mailer previews class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UserMailerPreview < ActionMailer::Preview

  def invitation
    UserMailer.invitation('sid@test.com')
  end

  def report
    UserMailer.report('Test Election', 1234567890, 567890, 'Reason')
  end
end