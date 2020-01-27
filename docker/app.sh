#
# App shell command file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Initialise the database (if not already done).
until bundle exec rake db:setup; do
  sleep 5
done

# Run delayed jobs.
bin/delayed_job --pool=vmv_mailers:1 --pool=*:1 start

# Run Puma for the app.
bundle exec puma -C config/puma.rb
