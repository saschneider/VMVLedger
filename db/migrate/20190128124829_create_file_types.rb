#
# File types migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateFileTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :file_types do |t|
      t.string :name, null: false
      t.integer :action, null: false, default: 0
      t.string :content_type, null: false
      t.boolean :public, null: false, default: false

      t.timestamps
    end

    add_index :file_types, :name, unique: true
  end
end
