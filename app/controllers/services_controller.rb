#
# Services controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ServicesController < ApplicationController
  before_action :set_service, only: [:edit, :update]

  #
  # GET /services/1/edit
  #
  def edit
    authorize @service
  end

  #
  # PATCH/PUT /services/1
  #
  def update
    authorize @service

    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to root_path, notice: I18n.t('shared.messages.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  private

  #
  # Setup the resource.
  #
  def set_service
    @service = Service.get_service
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def service_params
    params.require(:service).permit(:ui_enabled, :jobs_enabled, :nodes, :download_from_blockchain, :retrieve_interval, :verify_email, :full_length_field)
  end
end
