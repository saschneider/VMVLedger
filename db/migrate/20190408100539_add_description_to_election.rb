#
# Add description to election migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddDescriptionToElection < ActiveRecord::Migration[5.2]
  def change
    add_column :elections, :description, :string
  end
end
