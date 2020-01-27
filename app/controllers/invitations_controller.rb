#
# Invitations controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:edit, :update, :destroy]

  #
  # GET /invitations
  # GET /invitations.js
  #
  def index
    @invitations = policy_scope(Invitation).order(sort_column.to_s + ' ' + sort_direction.to_s).page(params[:page]).per(params[:limit])
    authorize @invitations
  end

  #
  # GET /invitations/new
  #
  def new
    @invitation = Invitation.new
    authorize @invitation
  end

  #
  # GET /invitations/1/edit
  #
  def edit
    authorize @invitation
  end

  #
  # POST /invitations
  #
  def create
    @invitation = Invitation.new(invitation_params)
    authorize @invitation

    @invitation.creator = current_user.fullname

    respond_to do |format|
      if @invitation.save
        UserMailer.invitation(@invitation.email).deliver_later
        format.html { redirect_to invitations_url, notice: "#{I18n.t('shared.messages.created')} #{I18n.t('invitations.messages.email')}" }
      else
        format.html { render :new }
      end
    end
  end

  #
  # PATCH/PUT /invitations/1
  #
  def update
    authorize @invitation
    old_email = @invitation.email

    respond_to do |format|
      if @invitation.update(invitation_params)
        if @invitation.email != old_email
          UserMailer.invitation(@invitation.email).deliver_later
          format.html { redirect_to invitations_url, notice: "#{I18n.t('shared.messages.updated')} #{I18n.t('invitations.messages.email_updated')}" }
        else
          format.html { redirect_to invitations_url, notice: I18n.t('shared.messages.updated') }
        end
      else
        format.html { render :edit }
      end
    end
  end

  #
  # DELETE /invitations/1
  #
  def destroy
    authorize @invitation

    respond_to do |format|
      if @invitation.destroy
        format.html { redirect_to invitations_url, notice: I18n.t('shared.messages.destroyed') }
      else
        format.html { redirect_to invitations_url, alert: I18n.t('shared.messages.not_destroyed') }
      end
    end
  end

  private

  #
  # Setup the resource.
  #
  def set_invitation
    @invitation = Invitation.find(params[:id])
  end

  #
  # Never trust parameters from the scary Internet, only allow the white list through.
  #
  def invitation_params
    params.require(:invitation).permit(:email) # Not redeemed or creator.
  end

  #
  # Add in helper method for sort column.
  #
  helper_method :sort_column

  #
  # @returns The sort column.
  #
  def sort_column
    Invitation.column_names.include?(params[:sort].to_s) ? params[:sort].to_sym : :email
  end

end
