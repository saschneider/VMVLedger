#
# Content migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.references :upload, foreign_key: true, null: false
      t.integer :sequence, null: false
      t.text :field_0
      t.text :field_1
      t.text :field_2
      t.text :field_3
      t.text :field_4
      t.text :field_5
      t.text :field_6
      t.text :field_7
      t.text :field_8
      t.text :field_9

      t.timestamps
    end

    add_index :contents, [:upload_id, :sequence], unique: true
  end
end
