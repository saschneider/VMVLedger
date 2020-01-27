#
# File type hint migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddHintToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :hint, :string
  end
end
