#
# Audit log migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class CreateAuditLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true, null: true
      t.text :action, null: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
