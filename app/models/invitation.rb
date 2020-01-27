#
# Invitation model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Invitation < ApplicationRecord

  # Associations.
  has_one :user, inverse_of: :invitation, required: false

  # Validators.
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :redeemed, inclusion: { in: [true, false] }

end
