#
# Home controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class HomeController < ApplicationController
  before_action :authenticate_user!, only: []
  after_action :verify_authorized, only: []
  before_action :set_show_account, only: []

  #
  # GET /about
  #
  def about
  end

  #
  # Returns the Certbot challenge response.
  #
  def challenge
    # Use the request path (which we know) that includes the unknown challenge file name. We remove the leading '/' to get a relative path.
    render file: Rails.public_path.join(request.path[1..-1]), layout: false
  end

  #
  # GET /documents
  #
  def documents
  end

  #
  # GET /
  #
  def home
    if policy(Election).index?
      @elections = policy_scope(Election).recent
      authorize @elections, :index?
    end
  end

  #
  # GET /introduction
  #
  def introduction
  end

  #
  # GET /privacy
  #
  def privacy
  end

  #
  # GET /verifiable
  #
  def verifiable
  end
end
