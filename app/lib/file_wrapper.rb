#
# File wrapper class for contract.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class FileWrapper

  # Contract reader.
  attr_reader :contract

  #
  # Initialises the object.
  #
  # @param contract The underlying Quorum contract object.
  #
  def initialize(contract)
    @contract = contract
    @lock     = Mutex.new
  end

  #
  # Adds the content of a file to the contract. Only metadata about the file is added to the content. Note that the file content is passed as an IO object which
  # is then read into memory. The initial position of the IO object is not changed and when complete, the last position will not be rewound.
  #
  # @param file The file content to be added as an IO object.
  # @return A hash containing { filename: the content file name, content_type: the content type, checksum: a checksum of the file }.
  #
  def add(filename, content_type, file)
    # Get a checksum of the content.
    checksum = self.get_checksum(file)

    # Add a chunk which defines the metadata for the file.
    self.add_chunks("#{filename},#{content_type},#{checksum}")

    { filename: filename, content_type: content_type, checksum: checksum }
  end

  #
  # Converts the file content into an array of values where each item in the array is a group of values. The content is assumed to have been retrieved already.
  #
  # @param file The file content to be added as an IO object.
  # @return The content as an array of array values. The first entry in the array contains the names of each value in subsequent lines.
  #
  def convert(file)
    # Convert the content: delegated to sub-classes.
    self.convert_content(file)
  end

  #
  # Gets the content of the file from the contract as long as it matches the expected checksum.
  #
  # @param read_checksum The expected checksum.
  # @return A hash containing { filename: the content file name, content_type: the content type, checksum: a checksum of the file }.
  #
  def get(read_checksum)
    # Get the chunk which defines the metadata for the file.
    metadata       = self.get_chunks(0)
    filename       = nil
    content_type   = nil
    write_checksum = nil

    if metadata && metadata.size >= 1
      elements = metadata[0].split(',')
      if elements && elements.size >= 3
        filename       = elements[0]
        content_type   = elements[1]
        write_checksum = elements[2]
      end
    end

    # Validate the metadata.
    raise QuorumHelper::QuorumError, I18n.t('quorum_file_helper.file_wrapper.invalid_checksum', read: read_checksum, write: write_checksum) unless read_checksum == write_checksum

    { filename: filename, content_type: content_type, checksum: read_checksum }
  end

  protected

  #
  # Adds one or more chunks to the file. A mutex is used to ensure that the contract is not updated from other threads at the same time. However, this does not
  # prevent the contract being updated by an independent process with direct access to the Quorum node(s).
  #
  # @param chunks The array of the chunks to add.
  # @return The number of chunks added.
  #
  def add_chunks(chunks)
    chunks = [chunks] unless chunks.is_a?(Array)

    @lock.synchronize do
      log = defined?(logger) ? logger : Rails.logger
      log.info "adding #{chunks.size} chunks to contract #{@contract.address}"

      # Add all of the chunks.
      count        = self.get_number_of_chunks
      transactions = []
      i            = 1
      chunks.each do |chunk|
        log.info "adding chunk #{i} of #{chunks.size}"
        i += 1
        transactions << @contract.transact.add_chunk(chunk)
      end

      # Wait for the transactions to complete.
      interval   = [0.05 * chunks.size, 10].max
      timeout    = [chunks.size, 1].max * 2.seconds # Assume a worst case of 2 seconds per chunk...
      timeout    = [timeout, interval * 6].max # ... and a minimum of 6 intervals.
      start_time = Time.now

      loop do
        raise QuorumHelper::QuorumError, I18n.t('quorum_file_helper.file_wrapper.timeout') if ((Time.now - start_time) > timeout)

        complete_count = 0
        begin
          complete_count = transactions.count(&:mined?)
        rescue => e
          log.error "failed to get transaction complete count: #{e.message}"
        end
        log.info "complete count #{complete_count} of #{transactions.count}"
        break if complete_count == transactions.count

        sleep interval
      end

      actual   = self.get_number_of_chunks
      expected = count + chunks.size
      raise QuorumHelper::QuorumError, I18n.t('quorum_file_helper.file_wrapper.failed_add', actual: actual, expected: expected) unless actual >= expected
    end

    chunks.size
  end

  #
  # Gets a checksum of the content of the file (as an IO object). Override this method to provide a specific implementation.
  #
  # @param _file The file content to be checksumed as an IO object.
  # @return A checksum of the data.
  #
  def get_checksum(_file)
    raise NotImplementedError.new("#{self.class.name}#get_checksum is an abstract method.")
  end

  #
  # Converts the file content into an array of values where each item in the array is a group of values. Override this method to provide a specific implementation.
  #
  # @param file The file content to be added as an IO object.
  # @return The content as an array of array values. The first entry in the array contains the names of each value in subsequent lines.
  #
  def convert_content(_file)
    raise NotImplementedError.new("#{self.class.name}#convert_content is an abstract method.")
  end

  #
  # @return The number of chunks in the file.
  #
  def get_number_of_chunks
    @contract.call.get_number_of_chunks
  rescue => e
    raise QuorumHelper::QuorumError, I18n.t('quorum_file_helper.file_wrapper.call_failed', message: e.message)
  end

  #
  # Gets the required chunks from the file. Each chunk is returned in the order specified in the indices. All chunks in order are returned if no indices are
  # specified.
  #
  # @param indices Optional array of indices to the required chunks in the file starting at 0. If nil, the whole file will be returned as an array of chunks.
  # @return The array of chunks.
  #
  def get_chunks(indices = nil)
    indices ||= 0..(self.get_number_of_chunks - 1)
    indices = indices.to_a if indices.is_a?(Range)
    indices = [indices] unless indices.is_a?(Array)

    invalid = indices.select { |value| (value < 0) || (value >= self.get_number_of_chunks) }
    raise QuorumHelper::QuorumError, I18n.t('quorum_file_helper.file_wrapper.invalid_indices', invalid: invalid) unless invalid.empty?

    chunks = []

    indices.each do |index|
      chunks << @contract.call.get_chunk(index)
    end

    chunks
  end
end
