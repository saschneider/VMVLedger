#
# Application job class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ApplicationJob < ActiveJob::Base
  include ActionView::Helpers::DateHelper

  before_perform :set_process_priority

  # Error that will be raised if the job fails.
  class JobError < StandardError
  end

  # Constants.
  DISABLED_RETRY_INTERVAL = 5.minutes

  #
  # Perform the job, but only if job processing is enabled.
  #
  # @param args The job arguments.
  #
  def perform(*args)
    if Service.get_service.jobs_enabled?
      # Job processing is enabled.
      Delayed::Worker.logger.info "---> running #{self.class}(#{args.join(',')}) on #{self.queue_name} at priority #{Process::getpriority(Process::PRIO_PROCESS, 0)}"
      start_time = Time.current
      perform_if_enabled(*args)
      Delayed::Worker.logger.info "<--- finished #{self.class} after #{time_ago_in_words(start_time)}"
    else
      # Resubmit the job with the required parameters after the specified delay. If the inline adapter is being used, we just ignore this.
      Delayed::Worker.logger.warn "**** job processing disabled for #{self.class}"
      begin
        self.class.set(wait: DISABLED_RETRY_INTERVAL).perform_later(*args)
      rescue NotImplementedError => _e
        Delayed::Worker.logger.error "**** no job queue available for future job #{self.class}"
      end
    end
  end

  #
  # Perform the job. Override this method in your subclass to perform the job.
  #
  def perform_if_enabled(*args)
    raise NotImplementedError.new("#{self.class.name}#perform_if_enabled is an abstract method.")
  end

  private

  #
  # Sets the process priority for the job.
  #
  def set_process_priority
    Process.setpriority(Process::PRIO_PROCESS, 0, 10)
  end

end
