#
# Binary file wrapper class for contract.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class BinaryFileWrapper < FileWrapper

  # Binary file chunk size.
  CHUNK_SIZE = 20480.freeze

  #
  # Gets a checksum of the content of the file (as an IO object).
  #
  # @param _file The file content to be checksumed as an IO object.
  # @return A checksum of the data.
  #
  def get_checksum(file)
    # Read all of the data in chunks.
    chunks = []
    chunks << file.read(CHUNK_SIZE) until file.eof?

    # Add each chunk to the digest.
    digest = Digest::SHA256.new
    chunks.each do |chunk|
      digest << chunk
    end

    digest.base64digest
  end
end