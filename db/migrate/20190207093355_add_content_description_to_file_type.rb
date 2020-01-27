#
# File type content description migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddContentDescriptionToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :content_description, :text
  end
end
