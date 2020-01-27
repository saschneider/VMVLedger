#
# Pundit election policy class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ElectionPolicy < ApplicationPolicy

  #
  # @return Can access index?
  #
  def index?
    super || Service.get_service.ui_enabled?
  end

  #
  # @return Can access faq?
  #
  def faq?
    verify?
  end

  #
  # @return Can access report_my_vote?
  #
  def report_my_vote?
    verify?
  end

  #
  # @return Can access send_report?
  #
  def send_report?
    verify?
  end

  #
  # @return Can access status?
  #
  def status?
    in_scope? && record.status?
  end

  #
  # @return Can access verify?
  #
  def verify?
    in_scope? && record.verification?
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