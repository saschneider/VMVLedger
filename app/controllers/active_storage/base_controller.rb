#
# Active Storage base controller controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

#
# Override the base controller for all ActiveStorage controllers to inherit from ApplicationController to enforce authentication.
#
class ActiveStorage::BaseController < ApplicationController
  # Copied from original implementation.
  protect_from_forgery with: :exception

  # Turn off Pundit checking.
  after_action :verify_authorized, only: []
  after_action :verify_policy_scoped, only: []

  # Copied from original implementation.
  before_action do
    ActiveStorage::Current.host = request.base_url
  end
end
