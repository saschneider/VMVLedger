#
# Election migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateElections < ActiveRecord::Migration[5.2]
  def change
    create_table :elections do |t|
      t.string :name, null: false
      t.boolean :public, default: false, null: false

      t.timestamps
    end

    add_index :elections, :name, unique: true
  end
end
