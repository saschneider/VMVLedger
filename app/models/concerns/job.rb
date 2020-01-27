#
# Job concern class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module Job
  extend ActiveSupport::Concern

  #
  # Add in the required elements.
  #
  included do
    # Enums.
    enum status: { creating: 0, pending: 1, success: 2, failed: 3 }

    # Validators.
    validates :status, presence: true

    # Scopes.
    scope :is_success, -> { where(status: :success) }
    scope :status_map_select, -> { self.statuses.map { |status| [I18n.t("activerecord.attributes.job.#{status[0]}"), status[1]] } }
  end
end