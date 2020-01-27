#
# File type model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class FileType < ApplicationRecord
  include Public

  # Associations.
  has_many :uploads, inverse_of: :file_type, dependent: :restrict_with_error

  # Enums.
  enum action: { no_action: 0, browse: 1, vmv_proof_of_knowledge: 2, verificatum_proof_of_knowledge: 3 }
  enum stage: { no_stage: 0, setup: 1, pre_election: 2, post_election: 3 }

  # Validators.
  validates :name, :action, :stage, :content_type, :sequence, presence: true
  validates :convert_to_content, :needed_for_verify, :needed_for_status, inclusion: { in: [true, false] }
  validates :name, uniqueness: true

  # Scopes.
  scope :action_map_select, -> { FileType.actions.map { |key, _value| [I18n.t("activerecord.attributes.file_type.#{key}.name"), key] }.sort }
  scope :file_type_map_select, lambda {
    order(sequence: :asc, name: :asc)
      .map { |file_type| [I18n.t('activerecord.attributes.file_type.map_select', sequence: file_type.sequence, name: file_type.name, public: file_type.public? ? I18n.t('activerecord.attributes.file_type.map_select_public') : ''), file_type.id, { content_type: file_type.content_type, hint: file_type.hint }] }
  }
  scope :stage_map_select, -> { FileType.stages.map { |key, _value| [I18n.t("activerecord.attributes.file_type.#{key}.name"), key] }.sort }
end
