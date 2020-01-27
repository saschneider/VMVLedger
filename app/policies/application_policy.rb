#
# Pundit application policy class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ApplicationPolicy
  attr_reader :user, :record

  #
  # Initialise with the user and target record.
  #
  # @param user The user who is logged in.
  # @param record The target record (or class).
  #
  def initialize(user, record)
    @user   = user
    @record = record
  end

  #
  # @return Can access index?
  #
  def index?
    user && user.administrator?
  end

  #
  # @return Can access show?
  #
  def show?
    in_scope?
  end

  #
  # @return Can access create?
  #
  def create?
    user && user.administrator?
  end

  #
  # @return Can access new?
  #
  def new?
    create?
  end

  #
  # @return Can access update?
  #
  def update?
    user && user.administrator?
  end

  #
  # @return Can access edit?
  #
  def edit?
    update?
  end

  #
  # @return Can access destroy?
  #
  def destroy?
    user && user.administrator?
  end

  #
  # @return Is the record in scope?
  #
  def in_scope?
    scope.where(id: record.id).exists?
  end

  #
  # @return Scope for checks.
  #
  def scope
    Pundit.policy_scope!(user, record.class)
  end

  #
  # Scope class.
  #
  class Scope
    attr_reader :user, :scope

    #
    # Initialisation.
    #
    # @param user The user who is logged in.
    # @param scope The current scope.
    #
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    # Resolve the scope.
    def resolve
      if user && user.administrator?
        scope.all
      else
        scope.none
      end
    end
  end
end
