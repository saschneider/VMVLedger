#
# Content model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Content < ApplicationRecord

  # Associations.
  belongs_to :upload, inverse_of: :contents

  # Validators.
  validates :sequence, presence: true
  validates :sequence, uniqueness: { scope: :upload }

  # Scopes.
  scope :is_public, -> { joins(:upload).where('uploads.public = ?', true) }

  #
  # Converts a content field index into it's corresponding field symbol.
  #
  # @param index The field index.
  # @return The symbol of the content field given its index.
  #
  def self.field_index_to_sym(index)
    "field_#{index.to_s.rjust(2, '0')}".to_sym
  end
end
