#
# CSV file wrapper class for contract.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CSVFileWrapper < FileWrapper

  # Content type handled by this wrapper.
  CONTENT_TYPE = 'text/csv'.freeze

  #
  # Gets a checksum of the content of the file (as an IO object).
  #
  # @param _file The file content to be checksumed as an IO object.
  # @return A checksum of the data.
  #
  def get_checksum(file)
    # read all the data as lines.
    lines = file.readlines

    # Calculate a checksum over all of the lines.
    digest = Digest::SHA256.new
    lines.each { |line| digest << line }
    digest.base64digest
  end

  #
  # Converts the file content into an array of values where each item in the array is a group of values.
  #
  # @param file The file content to be added as an IO object.
  # @return The content as an array of array values. The first entry in the array contains the names of each value in subsequent lines.
  #
  def convert_content(file)
    content = []

    file.readlines.each do |line|
      values = []

      line.split(',').each_with_index do |field, i|
        values << field.strip.gsub(/\A"|"\Z/, '')
      end

      content << values
    end

    content
  end
end
