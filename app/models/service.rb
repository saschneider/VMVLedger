#
# Service model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class Service < ApplicationRecord

  # Callbacks.
  before_create :delete_cache
  before_update :delete_cache
  before_destroy :delete_cache

  # Validators.
  validates :ui_enabled, :jobs_enabled, :download_from_blockchain, inclusion: { in: [true, false] }
  validates :retrieve_interval, presence: true, duration: true

  #
  # @returns the current singleton service information.
  #
  def self.get_service
    Rails.cache.fetch(Service.get_key_cache_key) do
      Service.first || Service.new
    end
  end

  #
  # Gets a random node assuming the nodes have been saved in a comma separated list.
  #
  def get_random_node
    node = nil

    unless self.nodes.blank?
      urls   = self.nodes.split(',')
      random = rand(0..(urls.size - 1))
      node   = urls[random]
    end

    node
  end

  #
  # @returns The retrieve interval as a duration.
  #
  def retrieve_interval_duration
    ActiveSupport::Duration.parse(self.retrieve_interval)
  end

  private

  #
  # Deletes any cache items associated with the service record.
  #
  def delete_cache
    Rails.cache.delete(Service.get_key_cache_key)
  end

  #
  # Returns the cache key for the service record.
  #
  # @return The corresponding cache key.
  #
  def self.get_key_cache_key
    'service'
  end
end
