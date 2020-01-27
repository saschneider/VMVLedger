#
# Blockchain retrieve job class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class BlockchainRetrieveJob < ApplicationJob

  # Use a separate queue for blockchain retrieve jobs.
  BLOCKCHAIN_RETRIEVE_QUEUE = :blockchain_retrieve
  queue_as BLOCKCHAIN_RETRIEVE_QUEUE

  # Constants.
  JOB_INTERVAL = 5.minutes

  #
  # Perform the job.
  #
  def perform_if_enabled(upload_id = nil)
    upload = nil

    # If this is for a specific upload, find it.
    upload = Upload.find_by(id: upload_id) unless upload_id.blank?

    # If this is for any upload, find the next upload that needs to be retrieved. This is for any upload that can be retrieved and for which the last retrieval
    # has expired.
    upload = Upload.to_retrieve(Service.get_service.retrieve_interval_duration).first if upload.nil?

    # Exit if nothing to do.
    return if upload.nil?

    # Check that the upload is valid for retrieval.
    raise JobError, I18n.t('blockchain_retrieve_job.not_public', upload: upload.id) unless upload.public? && upload.file_type.public?
    raise JobError, I18n.t('blockchain_retrieve_job.not_uploaded', upload: upload.id) unless upload.success? && upload.address.present?

    # Retrieve the file.
    Delayed::Worker.logger.info("retrieving uploaded file from blockchain: upload #{upload.id} #{upload.file.filename}")
    success = upload.update_content!
    raise JobError, I18n.t('blockchain_retrieve_job.failed_download', upload: upload.id) unless success
  rescue => e
    # Re-raise the error.
    if e.instance_of?(JobError)
      raise e
    else
      raise JobError, I18n.t('blockchain_retrieve_job.failed_perform', upload: upload.nil? ? upload_id : upload.id, message: e.message)
    end
  ensure
    # Re-queue the job with no arguments, assuming nothing else has re-queued it already.
    begin
      BlockchainRetrieveJob.set(wait: JOB_INTERVAL).perform_later unless BlockchainRetrieveJob.is_queued?
    rescue NotImplementedError => _e
      Delayed::Worker.logger.error "**** no job queue available for future job #{self.class}"
    end
  end

  #
  # Is the job queued?
  #
  # @returns True if the job is already queued.
  #
  def self.is_queued?
    # Ignore failed or running jobs (potentially this job).
    Delayed::Job.where(failed_at: nil, locked_at: nil).where('queue like ?', "%#{BLOCKCHAIN_RETRIEVE_QUEUE}").count.positive?
  end
end
