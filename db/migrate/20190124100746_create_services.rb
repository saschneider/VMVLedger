#
# Service migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.boolean :ui_enabled, null: false, default: false
      t.boolean :jobs_enabled, null: false, default: false

      t.timestamps
    end
  end
end
