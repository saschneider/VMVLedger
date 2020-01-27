#
# User extra fields migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :forename, :string, null: false, default: ''
    add_column :users, :surname, :string, null: false, default: ''
    add_column :users, :terms_of_service, :boolean, null: false, default: false
    add_column :users, :time_zone, :string, null: false, default: 'London'
    add_column :users, :role, :integer, null: false, default: 0
  end
end
