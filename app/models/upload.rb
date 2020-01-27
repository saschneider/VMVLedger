#
# Upload model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Upload < ApplicationRecord
  include Public
  include Job

  # Associations.
  belongs_to :file_type, inverse_of: :uploads
  belongs_to :election, inverse_of: :uploads, touch: true
  has_many :contents, inverse_of: :upload, dependent: :destroy

  # Attachments.
  has_one_attached :file

  # Validators.
  validates :file, attached: true
  validates :address, :checksum, presence: true, if: -> { self.success? }
  validates :public, inclusion: { in: [false], message: I18n.t('activerecord.errors.models.upload.attributes.public') }, if: -> { !self.file_type&.public? }

  # Scopes.
  scope :to_retrieve, -> (age) do
    joins(:file_type)
      .where(public: true)
      .where('file_types.convert_to_content = ? AND uploads.address is not null AND (retrieved_at <= ? OR retrieved_at is NULL)', true, Time.current - age)
      .order(Arel.sql('CASE WHEN retrieved_at IS NULL THEN 0 ELSE 1 END, retrieved_at ASC, created_at ASC'))
  end

  #
  # Downloads the copy of the file attachment from the blockchain.
  #
  # @return A hash containing { io: the content of the file as an IO object, filename: the original file name, content_type: the content type, checksum: a checksum of the data, file: the associated file wrapper }.
  #
  def download_from_blockchain!
    result = nil

    if self.file_type
      # The download process depends upon the type of file and is performed against a random Quorum node.
      file_wrapper = QuorumFileHelper.wrapper_for_content(self.file_type.content_type)
      url          = Service.get_service.get_random_node

      if url && self.address
        # Perform the download.
        helper = QuorumFileHelper.new(url)
        file   = helper.get(self.address, file_wrapper)
        result = file.get(self.checksum)

        if result[:checksum] == self.checksum
          result[:io]   = StringIO.new(self.file.download)
          result[:file] = file
        else
          result = nil
        end
      end
    end

    result
  end

  #
  # Attempts to convert a field name into its corresponding field symbol.
  #
  # @param name The name of the field.
  # @return The symbol of the content field given its name.
  #
  def field_name_to_sym(name)
    field_names = self.get_field_names
    index       = field_names.find_index(name) if field_names
    index.nil? ? nil : Content.field_index_to_sym(index)
  end

  #
  # @return The names of the fields for the content from the first sequence associated with the upload. Assumes that the content has been loaded.
  #
  def get_field_names
    names  = nil
    header = self.contents.first

    if header
      field_keys = header.attributes.keys.sort.select { |k| k =~ /\Afield.*/ }
      names      = []

      field_keys.each do |field|
        names << header.attributes[field]
      end
    end

    names
  end

  #
  # Updates the associated content for the upload with the content of the file from the blockchain. This only works for content of an appropriate type.
  #
  def update_content!
    result = false

    if self&.file_type&.convert_to_content?
      content = self.download_from_blockchain!

      if content && content[:io] && content[:file]
        ActiveRecord::Base.transaction do
          # Destroy all existing content for the upload.
          self.contents.destroy_all

          # Update the content from the downloaded file.
          lines = content[:file].convert(content[:io])

          lines.each_with_index do |line, i|
            content = self.contents.new(sequence: i)

            line.each_with_index do |value, j|
              content[Content.field_index_to_sym(j)] = value
            end

            content.save!
            result = true
          end

          self.update!(retrieved_at: Time.current)
        end
      end
    else
      result = true
    end

    result
  end

  #
  # Uploads the file attachment to the blockchain.
  #
  # @return A hash containing { filename: the content file name, content_type: the content type, checksum: a checksum of the file, file: the associated file wrapper }.
  #
  def upload_to_blockchain!
    result = nil

    if self.file_type
      # The upload process depends upon the type of file and is performed against a random Quorum node.
      file_wrapper = QuorumFileHelper.wrapper_for_content(self.file_type.content_type)
      url          = Service.get_service.get_random_node

      if url && self.file.attached?
        # Perform the upload and record the contract address.
        helper        = QuorumFileHelper.new(url)
        file          = helper.create(file_wrapper)
        result        = file.add(self.file.filename, self.file_type.content_type, StringIO.new(self.file.download))
        result[:file] = file
        self.update!(address: file.contract.address, checksum: result[:checksum])
      end
    end

    result
  end
end
