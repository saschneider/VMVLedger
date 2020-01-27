#
# File type description migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddDescriptionToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :description, :text
  end
end
