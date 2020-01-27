#
# Application controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class ApplicationController < ActionController::Base

  # Configure Devise.
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, except: :not_found
  before_action :set_show_account, except: :not_found

  # Set up Pundit. By default, make sure resource actions are authorised by Pundit.  Individual controllers will override this. Devise looks after itself.
  include Pundit
  after_action :verify_authorized, except: :not_found, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  # Rescue from all exceptions.
  rescue_from Exception do |e|
    handle_exception(e)
  end

  #
  # After successful login, go to the correct page.
  #
  def after_sign_in_path_for(_resource)
    root_path
  end

  #
  # After successful logout, go to the correct page.
  #
  def after_sign_out_path_for(_resource)
    new_user_session_path
  end

  # Application wide callbacks.
  around_action :user_time_zone, if: -> { user_signed_in? }
  before_action :set_default_limit
  before_action :set_gon_variables

  # Catch all path access and audit it, even if Warden intercepts.
  Warden::Manager.before_failure { |_env, opts| AuditLog.create!(user: nil, action: opts[:attempted_path], status: 401) }
  after_action -> { AuditLog.create!(user: current_user, action: "#{request.method}: #{request.path}", status: response.status) }

  #
  # Renders the appropriate not found response.
  #
  def not_found
    redirect_to root_path, alert: I18n.t('unknown_route')
  end

  protected

  #
  # Sets the additional Devise parameters for the user model.
  #
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:forename, :surname, :terms_of_service, :time_zone]) # Not role.
    devise_parameter_sanitizer.permit(:account_update, keys: [:forename, :surname, :time_zone]) # Not role.
  end

  #
  # @return The default sort direction. Set @default_sort_direction to override this in a controller.
  #
  def default_sort_direction
    @default_sort_direction || 'asc'
  end

  #
  # Add in helper method for sort order.  To use sorting, you should define a controller-specific sort_column method.
  #
  helper_method :sort_direction

  #
  # @returns the sort direction to use.
  #
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
  end

  private

  #
  # Handles exceptions by rendering an appropriate response.
  #
  # @param e The exception to handle.
  #
  def handle_exception(e)
    logger.error "Caught exception for request: #{request.remote_ip}; #{request.request_method}; #{request.original_url}; #{params}; #{e}"

    if e.instance_of? ActionController::InvalidAuthenticityToken
      reset_session
      redirect_to new_user_session_path, alert: t('authenticity_token_error')
    elsif e.instance_of? Pundit::NotAuthorizedError
      redirect_to root_path, alert: t('authorisation_error')
    elsif e.instance_of? ActiveRecord::RecordNotFound
      redirect_to root_path, alert: t('record_not_found')
    else
      # Handle any unexpected errors.
      if (Rails.env.production? || Rails.env.docker?) && request.format.html?
        render_exception(e, nil, :internal_server_error, true)
      else
        raise e
      end
    end
  end

  #
  # Shows the exception page.
  #
  # @param e The exception to handle.
  # @param message The associated error message.
  # @param response_code The HTTP response code.
  # @param backtrace Output the backtrace? Default false.
  #
  def render_exception(e, message, response_code, backtrace = false)
    logger.error "Caught #{e.class.name} in ApplicationController: #{e.message} #{backtrace ? e.backtrace : ''}"
    @message   = message
    @exception = e

    respond_to do |format|
      format.html { render 'application/error', status: response_code }
      format.any { head response_code }
    end
  end

  #
  # Sets the default page limit.
  #
  def set_default_limit
    params[:limit] ||= Kaminari.config.default_per_page
  end

  #
  # Sets the global GON variables for JavaScript.
  #
  def set_gon_variables
    gon.modal_confirm_title  = I18n.t('shared.titles.confirm')
    gon.modal_confirm_commit = I18n.t('shared.controls.confirm')
    gon.modal_confirm_cancel = I18n.t('shared.controls.cancel')
  end

  #
  # Show the account menu?
  #
  def set_show_account
    @show_account = true
  end

  #
  # Set the time zone from the user record and execute the block.
  #
  # @param block The block to be executed.
  #
  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

end
