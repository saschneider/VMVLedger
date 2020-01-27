#
# Content index migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddIndexToContent < ActiveRecord::Migration[5.2]
  def change
    add_index :contents, [:upload_id, :id]
  end
end
