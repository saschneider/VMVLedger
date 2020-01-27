#
# Service nodes migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddNodesToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :nodes, :text
  end
end
