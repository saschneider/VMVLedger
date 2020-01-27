#
# Election survey URL migration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AddSurveyUrlToElection < ActiveRecord::Migration[5.2]
  def change
    add_column :elections, :survey_url, :text
  end
end
