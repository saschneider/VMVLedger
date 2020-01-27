#
# Verify controller class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'openssl'

class VerifyController < ApplicationController
  before_action :authenticate_user!, only: []
  before_action :set_show_account, only: []
  before_action :set_election
  before_action :set_vote_record, except: [:status]
  before_action :set_voter_record, only: [:status]

  # Constants used in verification. Note that where appropriate, these values must match the corresponding file type database seeds in db/seeds.rb
  ELECTION_PARAMETERS = 'Election Parameters'.freeze
  P_FIELD             = 'p'.freeze

  VOTERS_KEYS       = "Voters' Keys".freeze
  PRIVATE_KEY_FIELD = 2

  ENCRYPTED_VOTERS = 'Encrypted Votes with Tracker Numbers'.freeze
  BETA_FIELD       = 'beta'.freeze
  PUBLIC_KEY_FIELD = 'publicKeyTrapdoor'.freeze

  TRACKER_NUMBERS               = 'Tracker Numbers'.freeze
  TRACKER_NUMBER_IN_GROUP_FIELD = 'trackerNumberInGroup'.freeze
  TRACKER_NUMBER_FIELD          = 'trackerNumber'.freeze

  MIXED_VOTERS = 'Final Votes'.freeze

  PUBLIC_VOTERS_KEYS   = 'Voter Public Keys with Encrypted Tracker Numbers'.freeze
  ENCRYPTED_VOTE_FIELD = 'encryptedVote'.freeze

  #
  # GET /verify/faq
  #
  def faq
    authorize @election
  end

  #
  # GET /verify/report_my_vote
  #
  def report_my_vote
    authorize @election
  end

  #
  # POST /verify/send_report
  #
  def send_report
    authorize @election

    beta     = nil
    beta     = params[:beta].to_i if params[:beta]
    tracker  = nil
    tracker  = params[:tracker].to_i if params[:tracker]
    election = params[:election]
    reason   = params[:reason]

    respond_to do |format|
      if (beta || tracker) && election
        UserMailer.report(election, beta, tracker, reason).deliver_later
        format.html { redirect_to root_path, notice: I18n.t('shared.messages.verify_report') }
      else
        format.html { redirect_to root_path, alert: I18n.t('shared.messages.verify_not_report') }
      end
    end
  end

  #
  # GET /verify/status
  #
  def status
    authorize @election

    respond_to do |format|
      format.html { render :status, status: @voter_record.nil? ? :accepted : :ok }
    end
  end

  #
  # GET /verify
  #
  def verify
    authorize @election

    respond_to do |format|
      format.html { render :verify, status: @vote_record.nil? ? :accepted : :ok }
    end
  end

  private

  #
  # Get the election parameter p from the publicly retrieved data.
  #
  # @return The election parameter p or nil if not found.
  #
  def get_p
    p = nil

    # Get the retrieved public election parameters file and the associated field.
    election_parameters = @election.uploads.find_by(file_type: FileType.find_by(name: ELECTION_PARAMETERS))

    if election_parameters
      p_field = election_parameters.field_name_to_sym(P_FIELD)

      if p_field
        record = election_parameters.contents.last
        p      = record[p_field].to_i if record && record[p_field]
      end
    end

    p
  end

  #
  # From the supplied public key, find the corresponding user's private trapdoor key from the privately held data.
  #
  # @param public_key The public key used to lookup the private key.
  # @return The corresponding private key or nil if not found.
  #
  def get_private_key(public_key)
    private_key = nil

    voters_keys = @election.uploads.find_by(file_type: FileType.find_by(name: VOTERS_KEYS))

    if voters_keys && voters_keys.file.attached?
      content = Rails.cache.fetch(voters_keys) do
        voters_keys.file.download
      end

      if content
        lines = content.lines
        found = lines.find { |line| /#{public_key}/ =~ line }

        if found
          elements    = found.split(',')
          private_key = elements[PRIVATE_KEY_FIELD].strip.gsub(/\A"|"\Z/, '').to_i if elements.length > PRIVATE_KEY_FIELD
        end
      end
    end

    private_key
  end

  #
  # From the supplied tracker number in the group, find the corresponding tracker number from the publicly retrieved data.
  #
  # @param beta The beta used to lookup the public key.
  # @return A hash containing the corresponding public key or nil if not found: { :public_key, :upload }
  #
  def get_public_key(beta)
    public_key = nil

    # Get the retrieved public encrypted voters file and the associated fields.
    encrypted_voters = @election.uploads.find_by(file_type: FileType.find_by(name: ENCRYPTED_VOTERS))

    if encrypted_voters
      beta_field       = encrypted_voters.field_name_to_sym(BETA_FIELD)
      public_key_field = encrypted_voters.field_name_to_sym(PUBLIC_KEY_FIELD)

      if beta_field && public_key_field
        record     = encrypted_voters.contents.find_by(beta_field => beta)
        public_key = record[public_key_field].to_i if record && record[public_key_field]
      end
    end

    { public_key: public_key, upload: encrypted_voters }
  end

  #
  # From the supplied beta, find the corresponding user's public trapdoor key from the publicly retrieved data.
  #
  # @param tracker_number_in_group The tracker number in the group used to lookup the tracker number.
  # @return A hash containing the corresponding tracker number or nil if not found: { :tracker_number, :upload }
  #
  def get_tracker_number(tracker_number_in_group)
    tracker_number = nil

    # Get the retrieved public tracker numbers file and the associated fields.
    tracker_numbers = @election.uploads.find_by(file_type: FileType.find_by(name: TRACKER_NUMBERS))

    if tracker_numbers
      tracker_number_in_group_field = tracker_numbers.field_name_to_sym(TRACKER_NUMBER_IN_GROUP_FIELD)
      tracker_number_field          = tracker_numbers.field_name_to_sym(TRACKER_NUMBER_FIELD)

      if tracker_number_in_group_field && tracker_number_field
        record         = tracker_numbers.contents.find_by(tracker_number_in_group_field => tracker_number_in_group)
        tracker_number = record[tracker_number_field].to_i if record && record[tracker_number_field]
      end
    end

    { tracker_number: tracker_number, upload: tracker_numbers }
  end


  #
  # From the supplied beta, find the corresponding encrypted vote from the publicly retrieved data.
  #
  # @param beta The beta used to lookup the public key.
  # @return True if a vote has been cast for this beta, false if no vote has been cast, and nil if voting has not been completed.
  #
  def get_vote_cast(beta)
    vote_cast = nil

    # Get the retrieved public encrypted voters file and the associated fields.
    encrypted_voters = @election.uploads.find_by(file_type: FileType.find_by(name: ENCRYPTED_VOTERS))

    if encrypted_voters
      beta_field           = encrypted_voters.field_name_to_sym(BETA_FIELD)
      encrypted_vote_field = encrypted_voters.field_name_to_sym(ENCRYPTED_VOTE_FIELD)

      if beta_field && encrypted_vote_field
        record    = encrypted_voters.contents.find_by(beta_field => beta)
        vote_cast = record && !record[encrypted_vote_field].blank?
      end
    end

    vote_cast
  end

  #
  # From the supplied tracker number, find the corresponding vote record from the publicly retrieved data.
  #
  # @param tracker_number The tracker number to lookup the vote.
  # @return A hash containing the corresponding vote record or nil if not found: { :vote_record, :voters_field_names, :upload }
  #
  def get_vote_record(tracker_number)
    vote_record        = nil
    voters_field_names = nil

    # Get the retrieved public mixed voters file and the associated field.
    voters = @election.uploads.find_by(file_type: FileType.find_by(name: MIXED_VOTERS), public: true)

    if voters
      voters_field_names   = voters.get_field_names
      tracker_number_field = voters.field_name_to_sym(TRACKER_NUMBER_FIELD)

      if tracker_number_field
        vote_record = voters.contents.find_by(tracker_number_field => tracker_number)
      end
    end

    { vote_record: vote_record, voters_field_names: voters_field_names, upload: voters }
  end

  #
  # From the supplied beta, find the corresponding voter record from the publicly retrieved data.
  #
  # @param beta The beta to lookup the voter.
  # @return A hash containing the corresponding voter record or nil if not found: { :voter_record, :voters_field_names, :upload }
  #
  def get_voter_record(beta)
    voter_record       = nil
    voters_field_names = nil

    # Get the retrieved voter public keys file and the associated field.
    voters = @election.uploads.find_by(file_type: FileType.find_by(name: PUBLIC_VOTERS_KEYS))

    if voters
      voters_field_names = voters.get_field_names
      beta_field         = voters.field_name_to_sym(BETA_FIELD)

      if beta_field
        voter_record = voters.contents.find_by(beta_field => beta)
      end
    end

    { voter_record: voter_record, voters_field_names: voters_field_names, upload: voters }
  end

  #
  # Setup the election from its name.
  #
  def set_election
    @election = Election.find_by!(name: params[:election])
  end

  #
  # Setup the vote record.
  #
  def set_vote_record
    alpha          = params[:alpha].to_i
    beta           = params[:beta].to_i
    tracker_number = params[:tracker].to_i

    # Get public key from beta and then the corresponding private key.
    @uploads        = []
    public_key_data = get_public_key(beta)
    public_key      = public_key_data[:public_key]
    @uploads << public_key_data[:upload]

    private_key = get_private_key(public_key)

    # Get the election parameter p.
    p = get_p

    # Decrypt the alpha and beta to reveal the tracker number in the group. We use OpenSSL to perform modulo arithmetic on big integers. For further details, please
    # see the private VMV class DecryptTrackerNumberShellComponent and associated cryptographic operations.
    @vote_record        = nil
    @voters_field_names = nil

    if alpha && (alpha > 0) && beta && (beta > 0) && private_key && (private_key > 0) && p && (p > 0)
      tracker_number_in_group = alpha.to_bn.mod_exp(p.to_bn - 1 - private_key.to_bn, p.to_bn).mod_mul(beta.to_bn, p.to_bn).to_i

      # Lookup the tracker number from the tracker number in the group.
      tracker_number_data = get_tracker_number(tracker_number_in_group)
      tracker_number      = tracker_number_data[:tracker_number]
      @uploads << tracker_number_data[:upload]
    end

    # Lookup vote from tracker_number.
    if tracker_number && (tracker_number > 0)
      vote_data           = get_vote_record(tracker_number)
      @vote_record        = vote_data[:vote_record]
      @voters_field_names = vote_data[:voters_field_names]
      @uploads << vote_data[:upload]
    end

    @uploads.compact!
  end

  #
  # Setup the voter record.
  #
  def set_voter_record
    beta = params[:beta].to_i

    # Use the beta to find to find whether the voter exists and whether they have voted or not.
    @voter_record = nil
    @vote_cast    = nil

    if beta
      # Find the voter record.
      voter_data    = get_voter_record(beta)
      @voter_record = voter_data[:voter_record]

      # Find whether a vote has been cast against the beta.
      @vote_cast = get_vote_cast(beta)
    end
  end
end
