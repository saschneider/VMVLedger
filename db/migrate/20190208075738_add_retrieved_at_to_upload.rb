#
# Retrieved at upload migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddRetrievedAtToUpload < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :retrieved_at, :datetime
  end
end
