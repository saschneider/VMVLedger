#
# Invitation migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.string :email, null: false, default: ""
      t.boolean :redeemed, null: false, default: false
      t.string :creator

      t.timestamps
    end

    add_reference :users, :invitation, foreign_key: true

    add_index :invitations, :email, unique: true
  end
end
