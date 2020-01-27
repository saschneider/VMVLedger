#
# Users controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]

  #
  # GET /users
  # GET /users.js
  #
  def index
    @users = policy_scope(User).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @users
  end

  #
  # GET /users/1/edit
  #
  def edit
    authorize @user
  end

  #
  # PATCH/PUT /users/1
  #
  def update
    authorize @user

    respond_to do |format|
      if @user.update!(user_params)
        format.html { redirect_to users_url, notice: I18n.t('shared.messages.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  #
  # DELETE /users/1
  #
  def destroy
    authorize @user

    respond_to do |format|
      if @user.destroy
        format.html { redirect_to users_url, notice: I18n.t('shared.messages.destroyed') }
      else
        format.html { redirect_to users_url, alert: I18n.t('shared.messages.not_destroyed') }
      end
    end
  end

  private

  #
  # Setup the resource.
  #
  def set_user
    @user = User.find(params[:id])
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def user_params
    params.require(:user).permit(:forename, :surname, :time_zone) # Not role, password or email.
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    User.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :email
  end

end
