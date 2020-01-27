#
# Upload migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :uploads do |t|
      t.references :election, foreign_key: true, null: false
      t.references :file_type, foreign_key: true, null: false
      t.integer :status, null: false, default: 0
      t.string :address
      t.boolean :public, null: false, default: false

      t.timestamps
    end
  end
end
