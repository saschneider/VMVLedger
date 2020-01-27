#
# CSV file wrapper test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class CSVFileWrapperHelperTest < ActiveSupport::TestCase
  include QuorumTestHelper

  test 'should add, get and convert' do
    contract = TestContract.new([])

    file = CSVFileWrapper.new(contract)
    assert_not_nil file

    filename        = 'public-voters.csv'
    content_type    = 'text/csv'
    write_io        = File.open("test/fixtures/files/#{filename}")
    number_of_lines = write_io.readlines.size
    write_io.rewind

    write_content = file.add(filename, content_type, write_io)
    assert_not_nil write_content
    assert_not_nil write_content[:checksum]

    read_content = file.get(write_content[:checksum])
    assert_not_nil read_content
    assert_equal filename, read_content[:filename]
    assert_equal content_type, read_content[:content_type]
    assert_not_nil read_content[:checksum]

    write_io.rewind
    converted = file.convert(write_io)
    assert_not_nil converted
    assert_equal number_of_lines, converted.size

    number_of_values = converted.first.size
    converted.each do |line|
      assert_equal number_of_values, line.size
    end
  end
end