#
# Verify email service migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddVerifyEmailToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :verify_email, :string
  end
end
