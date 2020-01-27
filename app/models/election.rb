#
# Election model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Election < ApplicationRecord
  include Public

  # Associations.
  has_many :uploads, inverse_of: :election, dependent: :restrict_with_error

  # Validators.
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :survey_url, url: true, unless: -> { self.survey_url.blank? }

  # Scopes.
  scope :recent, -> { order(created_at: :desc).limit(3) }
  scope :election_map_select, -> { order(name: :asc).map { |election| [election.name, election.id] } }

  #
  # @return If the election has voter status available.
  #
  def status?
    # Any one file is enough.
    available = self.uploads.joins(:file_type).where('file_types.public = uploads.public AND needed_for_status = ?', true).count >= 1
    retrieved = self.uploads.joins(:file_type).where('uploads.public = ? AND needed_for_status = ? AND retrieved_at IS NOT NULL', true, true).count >= 1

    available && retrieved
  end

  #
  # @return If the election has voter verification available.
  #
  def verification?
    # All must be available.
    all_file_types = FileType.where(needed_for_verify: true)
    available      = self.uploads.joins(:file_type).where('file_types.public = uploads.public AND needed_for_verify = ?', true).count == all_file_types.count

    public_file_types = FileType.where(needed_for_verify: true, public: true)
    retrieved         = self.uploads.joins(:file_type).where('uploads.public = ? AND needed_for_verify = ? AND retrieved_at IS NOT NULL', true, true).count == public_file_types.count

    available && retrieved
  end
end
