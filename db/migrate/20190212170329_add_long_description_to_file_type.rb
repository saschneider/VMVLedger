#
# File type long description migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddLongDescriptionToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :long_description, :text
  end
end
