#
# File type group migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddGroupToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :stage, :integer, null: false, default: 0
  end
end
