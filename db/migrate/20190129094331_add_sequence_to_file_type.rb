#
# File type sequence migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddSequenceToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :sequence, :integer
    FileType.connection.execute('UPDATE file_types SET sequence = 0')
    change_column :file_types, :sequence, :integer, null: false

    add_index :file_types, :sequence
  end
end
