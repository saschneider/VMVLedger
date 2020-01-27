#
# Filter parameter logging initialisation file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :alpha]
