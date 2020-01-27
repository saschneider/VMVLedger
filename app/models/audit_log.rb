#
# Audit log model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AuditLog < ApplicationRecord

  # Associations.
  belongs_to :user, inverse_of: :audit_logs, required: false

  # Validators.
  validates :action, :status, presence: true

end
