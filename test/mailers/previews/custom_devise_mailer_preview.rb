#
# Devise mailer previews class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CustomDeviseMailerPreview < ActionMailer::Preview

  def confirmation_instructions
    user = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    CustomDeviseMailer.confirmation_instructions(user, 'faketoken')
  end

  def email_changed
    user = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    CustomDeviseMailer.email_changed(user)
  end

  def password_change
    user = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    CustomDeviseMailer.password_change(user)
  end

  def reset_password_instructions
    user = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    CustomDeviseMailer.reset_password_instructions(user, 'faketoken')
  end

  def unlock_instructions
    user = User.new(email: 'george@smith.com', forename: 'George', surname: 'Smith', terms_of_service: true)
    CustomDeviseMailer.unlock_instructions(user, 'faketoken')
  end
end