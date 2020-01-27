#
# Pundit content policy class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ContentPolicy < ApplicationPolicy

  #
  # @return Can access index?
  #
  def index?
    super || Service.get_service.ui_enabled?
  end

  #
  # @return Can access create?
  #
  def create?
    false
  end

  #
  # @return Can access update?
  #
  def update?
    false
  end

  #
  # @return Can access destroy?
  #
  def destroy?
    false
  end

  #
  # Scope class.
  #
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user && user.administrator?
        scope.all
      elsif Service.get_service.ui_enabled?
        scope.is_public
      else
        scope.none
      end
    end
  end
end