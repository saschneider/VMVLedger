#
# More content field migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddMoreFieldsToContent < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :field_10, :text
    add_column :contents, :field_11, :text
    add_column :contents, :field_12, :text
    add_column :contents, :field_13, :text
    add_column :contents, :field_14, :text
    add_column :contents, :field_15, :text
    add_column :contents, :field_16, :text
    add_column :contents, :field_17, :text
    add_column :contents, :field_18, :text
    add_column :contents, :field_19, :text
    add_column :contents, :field_20, :text
    add_column :contents, :field_21, :text
    add_column :contents, :field_22, :text
    add_column :contents, :field_23, :text
    add_column :contents, :field_24, :text
    add_column :contents, :field_25, :text
  end
end
