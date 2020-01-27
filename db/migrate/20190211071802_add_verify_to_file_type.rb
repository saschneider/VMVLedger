#
# Verify file types migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddVerifyToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :needed_for_verify, :boolean, default: false
  end
end
