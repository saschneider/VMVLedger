#
# Blockchain commit job class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class BlockchainCommitJob < ApplicationJob

  # Use a separate queue for blockchain commit jobs.
  BLOCKCHAIN_COMMIT_QUEUE = :blockchain_commit
  queue_as BLOCKCHAIN_COMMIT_QUEUE

  #
  # Perform the job.
  #
  def perform_if_enabled(upload_id)
    success = false
    upload  = nil

    begin
      # Find the upload.
      upload = Upload.find(upload_id)

      # Check that the upload is valid for committing.
      raise JobError, I18n.t('blockchain_commit_job.not_public', upload: upload_id) unless upload.public? && upload.file_type.public?
      raise JobError, I18n.t('blockchain_commit_job.duplicate_upload', upload: upload_id) unless (upload.creating? || upload.failed?) && upload.address.blank?

      # Commit the file.
      upload.update!(status: :pending)
      Delayed::Worker.logger.info("committing uploaded file to blockchain: upload #{upload_id}")
      success = !upload.upload_to_blockchain!.nil?
      raise JobError, I18n.t('blockchain_commit_job.failed_upload', upload: upload_id) unless success
    rescue => e
      # Re-raise the error.
      if e.instance_of?(JobError)
        raise e
      else
        raise JobError, I18n.t('blockchain_commit_job.failed_perform', upload: upload_id, message: e.message)
      end
    ensure
      upload.update!(status: success ? :success : :failed) unless upload.nil?
      BlockchainRetrieveJob.perform_later(upload_id) if success
    end
  end
end
