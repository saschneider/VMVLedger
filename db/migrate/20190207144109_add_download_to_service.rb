#
# Service download form blockchain option migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddDownloadToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :download_from_blockchain, :boolean, default: false
  end
end
