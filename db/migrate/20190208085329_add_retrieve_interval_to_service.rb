#
# Retrieve interval service option migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddRetrieveIntervalToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :retrieve_interval, :string, null: false, default: 'PT60M'
  end
end
