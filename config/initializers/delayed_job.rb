#
# Delayed job configuration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Configure the queue.
Delayed::Worker.destroy_failed_jobs     = false
Delayed::Worker.sleep_delay             = 5
Delayed::Worker.max_attempts            = 1
Delayed::Worker.max_run_time            = 12.hours
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.read_ahead              = 10

# Don't run delayed for development or testing unless overridden.
Delayed::Worker.delay_jobs = !Rails.env.development? && !Rails.env.test?
Delayed::Worker.delay_jobs |= ENV['DELAYED_JOBS'].present?

# Log to a separate file.
Delayed::Worker.logger            = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
Delayed::Worker.logger.level      = Logger::INFO # Output informational messages and above.
Delayed::Worker.default_log_level = Logger::DEBUG # Delayed job default logging is debug.

# Queue priorities.
Delayed::Worker.queue_attributes = {
  # Top priority jobs.
  ActionMailer::Base.deliver_later_queue_name => { priority: -10 },

  # Medium priority jobs: dealing with uploads.
  :active_storage => { priority: 5 }, # See initializers/active_storage.rb
  BlockchainCommitJob::BLOCKCHAIN_COMMIT_QUEUE     => { priority: 5 },
  BlockchainRetrieveJob::BLOCKCHAIN_RETRIEVE_QUEUE => { priority: 10 },
}

# Send an email on any error.
Delayed::Worker.class_eval do

  #
  # Sends an email when a job fails.
  #
  # @param job The job that failed.
  # @param error The error it failed with.
  #
  def handle_failed_job_with_email(job, error)
    handle_failed_job_without_email(job, error)

    # Make sure we do not repeat the same error over and over again. This will only work within the same Delayed Job process.
    email = true

    if @last_error && (@last_error.message == error.message)
      Delayed::Worker.logger.warn "not repeating #{error.message}"
      email = false
    end

    @last_error = error

    begin
      JobMailer.error(error, 'Worker').deliver_now if email && !error.instance_of?(SignalException)
    rescue => e
      Delayed::Worker.logger.error "could not send error email: #{e.message}: #{e.backtrace}"
    end
  end

  alias_method :handle_failed_job_without_email, :handle_failed_job
  alias_method :handle_failed_job, :handle_failed_job_with_email

end