#
# Convert tto content file type migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddConvertToContentToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :convert_to_content, :boolean, null: false, default: false
  end
end
