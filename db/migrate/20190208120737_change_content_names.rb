#
# Change content fields migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ChangeContentNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :contents, :field_0, :field_00
    rename_column :contents, :field_1, :field_01
    rename_column :contents, :field_2, :field_02
    rename_column :contents, :field_3, :field_03
    rename_column :contents, :field_4, :field_04
    rename_column :contents, :field_5, :field_05
    rename_column :contents, :field_6, :field_06
    rename_column :contents, :field_7, :field_07
    rename_column :contents, :field_8, :field_08
    rename_column :contents, :field_9, :field_09
  end
end
