#
# Contents controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ContentsController < ApplicationController
  before_action :set_content, only: [:show]
  before_action :set_upload
  before_action :set_field_names
  before_action :authenticate_user!, only: []
  before_action :set_show_account, only: []
  before_action :set_page, only: [:index]
  before_action :set_full_length_fields, only: [:index]

  #
  # GET /contents
  # GET /contents.js
  #
  def index
    authorize @upload.election, :show?
    authorize @upload, :show?
    redirect_to root_path, alert: I18n.t('contents.messages.no_blockchain_attachment') if @upload.address.nil?

    @contents = policy_scope(Content).where(upload: @upload).where('sequence > 0').order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @contents
  end

  #
  # GET /contents/1
  #
  def show
    authorize @upload.election, :show?
    authorize @upload, :show?
    redirect_to root_path, alert: I18n.t('contents.messages.no_blockchain_attachment') if @upload.address.nil?

    authorize @content
  end

  private

  #
  # Setup the resource.
  #
  def set_content
    @content = Content.find(params[:id])
  end

  #
  # Setup the parent resource field names.
  #
  def set_field_names
    @field_names = nil
    @field_names = @upload.get_field_names if @upload
  end

  #
  # Sets the full length field options.
  #
  def set_full_length_fields
    @full_length_fields = []
    @full_length_fields = Service.get_service.full_length_field.split(',') unless Service.get_service.full_length_field.blank?
  end

  #
  # Optionally find the page on which a specific field value (the first) can be found. We do this only for HTML pages so that AJAX page requests continue to
  # return different pages.
  #
  def set_page
    if request.format.html? && params[:field] && params[:value]
      field = Content.field_index_to_sym(params[:field])

      if Content.column_names.include?(field.to_s)
        matches = policy_scope(Content).where(upload: @upload).where('sequence > 0').order(sort_column.to_s + ' ' + sort_direction.to_s)
                    .select(Content.sanitize_sql_for_conditions(["#{field} = ? as matches", params[:value]]))
        index   = matches.to_a.find_index { |content| ActiveModel::Type::Boolean.new.cast(content[:matches]) }

        if index
          page          ||= index / params[:limit]
          params[:page] = page + 1 if page && page > 0
        end
      end
    end
  end

  #
  # Setup the parent resource.
  #
  def set_upload
    @upload = nil
    @upload = Upload.find(params[:upload_id]) if params[:upload_id]
    @upload = @content.upload if @upload.nil? && !@content.nil?
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    Content.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :sequence
  end
end
