#
# File types controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class FileTypesController < ApplicationController
  before_action :set_file_type, only: [:show, :edit, :update, :destroy]

  #
  # GET /file_types
  # GET /file_types.js
  #
  def index
    @file_types = policy_scope(FileType).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @file_types
  end

  #
  # GET /file_types/1
  #
  def show
    authorize @file_type
  end

  #
  # GET /file_types/new
  #
  def new
    @file_type = FileType.new
    authorize @file_type
  end

  #
  # GET /file_types/1/edit
  #
  def edit
    authorize @file_type
  end

  #
  # POST /file_types
  #
  def create
    @file_type = FileType.new(file_type_params)
    authorize @file_type

    respond_to do |format|
      if @file_type.save
        format.html { redirect_to file_types_url, notice: I18n.t('shared.messages.created') }
      else
        format.html { render :new }
      end
    end
  end

  #
  # PATCH/PUT /file_types/1
  #
  def update
    authorize @file_type

    respond_to do |format|
      if @file_type.update(file_type_params)
        format.html { redirect_to file_types_url, notice: I18n.t('shared.messages.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  #
  # DELETE /file_types/1
  #
  def destroy
    authorize @file_type

    respond_to do |format|
      if @file_type.destroy
        format.html { redirect_to file_types_url, notice: I18n.t('shared.messages.destroyed') }
      else
        format.html { redirect_to file_types_url, alert: I18n.t('shared.messages.not_destroyed') }
      end
    end
  end

  private

  #
  # Setup the resource.
  #
  def set_file_type
    @file_type = FileType.find(params[:id])
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def file_type_params
    params.require(:file_type).permit(:name, :action, :stage, :content_type, :sequence, :public, :convert_to_content,
                                      :description, :long_description, :content_description,
                                      :needed_for_verify, :needed_for_status, :hint)
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    FileType.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :sequence
  end
end
