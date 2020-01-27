#
# File wrapper test class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'
require 'quorum_test_helper'
require 'webmock/minitest'

class FileWrapperHelperTest < ActiveSupport::TestCase
  include QuorumTestHelper

  class TestFileWrapper < FileWrapper

    def public_add_chunks(chunks)
      self.add_chunks(chunks)
    end

    def public_get_chunks(indices = nil)
      self.get_chunks(indices)
    end

    def public_get_number_of_chunks
      self.get_number_of_chunks
    end

    protected

    def get_checksum(_file)
      'checksum'
    end
  end

  test 'should wrap file contract' do
    chunks   = %w(1 2 3)
    contract = TestContract.new(chunks)

    file = TestFileWrapper.new(contract)
    assert_not_nil file

    assert_equal chunks.size, file.public_get_number_of_chunks
    assert_equal chunks, file.public_get_chunks
    assert_equal chunks[0..1], file.public_get_chunks(0..1)
    assert_equal chunks[1..2], file.public_get_chunks([1, 2])
    assert_equal [chunks[2]], file.public_get_chunks(2)

    assert_equal 1, file.public_add_chunks('4')
    assert_equal 2, file.public_add_chunks(%w(4 5))
    assert_equal chunks.size, file.public_get_number_of_chunks
  end

  test 'should add and get' do
    write_io = StringIO.new

    number_of_characters = 1024
    number_of_lines      = 100

    line = ''
    (1..number_of_characters).each { line << '.' }
    (1..number_of_lines).each { write_io.puts(line) }
    write_io.rewind

    contract = TestContract.new([])

    file = TestFileWrapper.new(contract)
    assert_not_nil file

    filename     = 'test.txt'
    content_type = 'text/plain'

    write_content = file.add(filename, content_type, write_io)
    assert_not_nil write_content
    assert_not_nil write_content[:checksum]

    read_content = file.get(write_content[:checksum])
    assert_not_nil read_content
    assert_equal filename, read_content[:filename]
    assert_equal content_type, read_content[:content_type]
    assert_not_nil read_content[:checksum]
  end

  test 'should add and get but wrong checksum' do
    write_io = StringIO.new

    number_of_characters = 1024
    number_of_lines      = 100

    line = ''
    (1..number_of_characters).each { line << '.' }
    (1..number_of_lines).each { write_io.puts(line) }
    write_io.rewind

    contract = TestContract.new([])

    file = TestFileWrapper.new(contract)
    assert_not_nil file

    filename     = 'test.txt'
    content_type = 'text/plain'

    write_content = file.add(filename, content_type, write_io)
    assert_not_nil write_content
    assert_not_nil write_content[:checksum]

    assert_raises QuorumHelper::QuorumError do
      file.get('rubbish')
    end
  end

  test 'should not add as abstract' do
    io = StringIO.new

    number_of_characters = 1024
    number_of_lines      = 100

    line = ''
    (1..number_of_characters).each { line << '.' }
    (1..number_of_lines).each { io.write(line) }

    contract = TestContract.new([])

    file = FileWrapper.new(contract)
    assert_not_nil file

    filename     = 'test.txt'
    content_type = 'text/plain'

    assert_raises NotImplementedError do
      file.add(filename, content_type, io)
    end
  end

  test 'should not convert as abstract' do
    contract = TestContract.new([])

    file = FileWrapper.new(contract)
    assert_not_nil file

    assert_raises NotImplementedError do
      file.convert(StringIO.new)
    end
  end
end