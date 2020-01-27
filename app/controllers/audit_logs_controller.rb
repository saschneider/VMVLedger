#
# Audit logs controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AuditLogsController < ApplicationController
  before_action -> { @default_sort_direction = 'desc' }

  #
  # GET /audit_logs
  # GET /audit_logs.js
  #
  def index
    @audit_logs = policy_scope(AuditLog).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @audit_logs
  end

  private

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    AuditLog.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :created_at
  end
end
