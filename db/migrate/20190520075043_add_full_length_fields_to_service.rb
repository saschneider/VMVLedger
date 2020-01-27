#
# Add full length field to services migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddFullLengthFieldsToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :full_length_field, :text
  end
end
