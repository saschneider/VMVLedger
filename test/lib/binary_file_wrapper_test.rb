#
# Binary file wrapper test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class BinaryFileWrapperHelperTest < ActiveSupport::TestCase
  include QuorumTestHelper

  test 'should add and get' do
    contract = TestContract.new([])

    file = BinaryFileWrapper.new(contract)
    assert_not_nil file

    filename     = 'shuffle-proofs-1.zip'
    content_type = 'application/zip'
    write_io     = File.open("test/fixtures/files/#{filename}")

    write_content = file.add(filename, content_type, write_io)
    assert_not_nil write_content
    assert_not_nil write_content[:checksum]

    read_content = file.get(write_content[:checksum])
    assert_not_nil read_content
    assert_equal filename, read_content[:filename]
    assert_equal content_type, read_content[:content_type]
    assert_not_nil read_content[:checksum]
  end

  test 'should not convert as abstract' do
    contract = TestContract.new([])

    file = BinaryFileWrapper.new(contract)
    assert_not_nil file

    assert_raises NotImplementedError do
      file.convert(StringIO.new)
    end
  end
end