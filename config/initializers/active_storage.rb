#
# Active storage initialisation file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Set the Active Storage options. Note that we turn off all analyzers because, for example, the ImageAnalyzer will download the large NDVI files and then fail to
# analyse them because they are GeoTIFFs.
Rails.application.config.active_storage.queue     = :active_storage # See initializers/delayed_job.rb
Rails.application.config.active_storage.analyzers = []
