#
# Upload checksum migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddChecksumToUpload < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :checksum, :string
  end
end
