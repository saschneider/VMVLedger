#
# Uploads controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UploadsController < ApplicationController
  before_action :set_upload, only: [:show, :blockchain, :download, :edit, :update, :recommit, :retrieve]
  before_action :authenticate_user!, except: [:blockchain, :download]
  before_action :set_show_account, except: [:blockchain, :download]
  before_action :set_election, only: [:index]

  #
  # GET /uploads/1/blockchain
  #
  def blockchain
    authorize @upload.election, :show?
    authorize @upload

    # Obtain blockchain version of file and send it back.
    content = nil
    content = @upload.download_from_blockchain! if @upload.address

    if content && content[:io]
      send_data content[:io].read, filename: @upload.file.filename, type: @upload.file_type.content_type, disposition: 'attachment', status: :ok
    else
      redirect_to root_path, alert: I18n.t('uploads.messages.no_blockchain_attachment')
    end
  end

  #
  # GET /uploads/1/download
  #
  def download
    authorize @upload.election, :show?
    authorize @upload

    # Obtain the ActiveStorage version of the file and send it back.
    if @upload.file.attached?
      send_data @upload.file.download, filename: @upload.file.filename, type: @upload.file_type.content_type, disposition: 'attachment', status: :ok
    else
      redirect_to root_path, alert: I18n.t('uploads.messages.no_download_attachment')
    end
  end

  #
  # GET /uploads
  # GET /uploads.js
  #
  def index
    # Optionally filter by election.
    if @election
      @uploads = policy_scope(Upload).where(election: @election).joins(:file_type).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    else
      @uploads = policy_scope(Upload).joins(:file_type).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    end

    authorize @uploads
  end

  #
  # GET /uploads/1
  #
  def show
    authorize @upload
  end

  #
  # GET /uploads/new
  #
  def new
    @upload = Upload.new
    authorize @upload
  end

  #
  # GET /uploads/1/edit
  #
  def edit
    authorize @upload
  end

  #
  # POST /uploads
  #
  def create
    @upload = Upload.new(upload_params)
    authorize @upload

    respond_to do |format|
      if @upload.save
        commit_file
        format.html { redirect_to uploads_url, notice: I18n.t('shared.messages.created') }
      else
        format.html { render :new }
      end
    end
  end

  #
  # PATCH/PUT /uploads/1
  #
  def update
    authorize @upload

    respond_to do |format|
      if @upload.update(upload_params)
        commit_file
        format.html { redirect_to uploads_url, notice: I18n.t('shared.messages.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  #
  # POST /images/1/recommit
  #
  def recommit
    authorize @upload

    respond_to do |format|
      commit_file
      format.html { redirect_to uploads_url, notice: I18n.t('uploads.messages.recommit') }
    end
  end

  #
  # POST /images/1/retrieve
  #
  def retrieve
    authorize @upload

    respond_to do |format|
      retrieve_file
      format.html { redirect_to uploads_url, notice: I18n.t('uploads.messages.retrieve') }
    end
  end

  private

  #
  # Determines if the uploaded file should be committed to the blockchain and if so, commits it.
  #
  def commit_file
    if @upload.public? && @upload.file_type.public? && @upload.address.blank? && (@upload.creating? || @upload.failed?)
      BlockchainCommitJob.perform_later(@upload.id)
    end
  end

  #
  # Determines if the uploaded file can be retrieved from the blockchain and if so, retrieves it.
  #
  def retrieve_file
    if @upload.public? && @upload.file_type.public? && @upload.address.present? && @upload.success?
      BlockchainRetrieveJob.perform_later(@upload.id)
    end
  end

  #
  # Setup the parent resource.
  #
  def set_election
    @election = nil
    @election = Election.find(params[:filter]) if params[:filter]
    @election = Election.find(params[:election_id]) if params[:election_id]
  end

  #
  # Setup the resource.
  #
  def set_upload
    @upload = Upload.find(params[:id])
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def upload_params
    params.require(:upload).permit(:election_id, :file_type_id, :public, :file) # Not status, address or checksum.
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    column = Upload.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : 'file_types.sequence'.to_sym

    # Deal with the join tables.
    table_columns = params[:sort].to_s.split('.')
    column        = FileType.column_names.include?(table_columns[1].to_s) ? params[:sort].to_sym : column if table_columns.size >= 2 && table_columns[0] == FileType.table_name
    column        = FileType.column_names.include?(table_columns[1].to_s) ? params[:sort].to_sym : column if table_columns.size >= 2 && table_columns[0] == Upload.table_name

    column
  end
end
