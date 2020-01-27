#
# Elections controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ElectionsController < ApplicationController
  before_action :set_election, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_show_account, except: [:index, :show]

  #
  # GET /elections
  # GET /elections.js
  #
  def index
    @elections = policy_scope(Election).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @elections
  end

  #
  # GET /elections/1
  # GET /elections/1.js
  #
  def show
    authorize @election

    # Setup the uploads for the selected election.
    @uploads = @election.uploads.is_public.is_success.joins(:file_type).order(sort_column.to_s + ' ' + sort_direction.to_s)
  end

  #
  # GET /elections/new
  #
  def new
    @election = Election.new
    authorize @election
  end

  #
  # GET /elections/1/edit
  #
  def edit
    authorize @election
  end

  #
  # POST /elections
  #
  def create
    @election = Election.new(election_params)
    authorize @election

    respond_to do |format|
      if @election.save
        format.html { redirect_to elections_url, notice: I18n.t('shared.messages.created') }
      else
        format.html { render :new }
      end
    end
  end

  #
  # PATCH/PUT /elections/1
  #
  def update
    authorize @election

    respond_to do |format|
      if @election.update(election_params)
        format.html { redirect_to elections_url, notice: I18n.t('shared.messages.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  #
  # DELETE /elections/1
  #
  def destroy
    authorize @election

    respond_to do |format|
      if @election.destroy
        format.html { redirect_to elections_url, notice: I18n.t('shared.messages.destroyed') }
      else
        format.html { redirect_to elections_url, alert: I18n.t('shared.messages.not_destroyed') }
      end
    end
  end

  private

  #
  # Setup the resource.
  #
  def set_election
    @election = Election.find(params[:id])
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def election_params
    params.require(:election).permit(:name, :public, :survey_url, :description)
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    if action_name.to_sym == :index
      Election.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :name
    else
      column = Upload.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : 'file_types.sequence'.to_sym

      # Deal with the join table.
      table_columns = params[:sort].to_s.split('.')
      column        = FileType.column_names.include?(table_columns[1].to_s) ? params[:sort].to_sym : column if table_columns.size >= 2 && table_columns[0] == FileType.table_name

      column
    end
  end
end
