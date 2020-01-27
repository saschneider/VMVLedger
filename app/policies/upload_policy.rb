#
# Pundit upload policy class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UploadPolicy < ApplicationPolicy

  #
  # @return Can access blockchain?
  #
  def blockchain?
    show?
  end

  #
  # @return Can access destroy?
  #
  def destroy?
    false
  end

  #
  # @return Can access download?
  #
  def download?
    show?
  end

  #
  # @return Can access recommit?
  #
  def recommit?
    update?
  end

  #
  # @return Can access retrieve?
  #
  def retrieve?
    update?
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