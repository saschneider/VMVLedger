#
# Custom Devise user registrations controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Users::RegistrationsController < Devise::RegistrationsController

  protected

  #
  # @return the path used after sign up.
  #
  def after_sign_up_path_for(resource)
    new_session_path(resource)
  end

  #
  # @return the path used after sign up for inactive accounts.
  #
  def after_inactive_sign_up_path_for(resource)
    after_sign_up_path_for(resource)
  end
end
