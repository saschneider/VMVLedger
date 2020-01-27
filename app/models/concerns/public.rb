#
# Public concern class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module Public
  extend ActiveSupport::Concern

  #
  # Add in the required elements.
  #
  included do
    # Validators.
    validates :public, inclusion: { in: [true, false] }

    # Scopes.
    scope :is_public, -> { where(public: true) }
  end
end