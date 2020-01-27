#
# User model file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class User < ApplicationRecord

  # Setup the devise environment.
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :validatable, :lockable, :trackable

  # Role enum - for future use only.
  #  Administrator: can access and modify everything.
  enum role: { administrator: 0 }

  # Associations.
  belongs_to :invitation, inverse_of: :user, dependent: :destroy, required: false # Not required to remove validation error message, but checked below anyway.
  has_many :audit_logs, inverse_of: :user, dependent: :nullify

  # Callbacks.
  before_validation :set_invitation, on: :create
  after_create :redeem_invitation

  # Validators.
  validate :password_complexity
  validates :email, :forename, :surname, :terms_of_service, presence: true
  validates :invitation, presence: { message: I18n.t('users.messages.not_invited') }
  validates :terms_of_service, acceptance: { accept: true }
  validates :email, uniqueness: { case_sensitive: false }

  # Returns the full name of the user.
  def fullname
    "#{forename} #{surname}"
  end

  #
  # Sends Devise emails asynchronously.
  #
  # @param notification The notification email to be sent.
  # @param args Optional arguments.
  #
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  #
  # Make sure that the password is sufficient complex: at least one uppercase, one lowercase and one digit.
  #
  def password_complexity
    if password.present? and not password.match(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*/)
      errors.add :password, I18n.t('weak_password')
    end
  end

  #
  # Marks the invitation as redeemed.
  #
  def redeem_invitation
    # If we use self.invitation.update here, it causes a problem because we are still in the create transaction.
    arel       = Invitation.arel_table
    invitation = Invitation.find_by(arel[:email].matches(self.email))
    invitation.update(redeemed: true) unless invitation.nil?
  end

  #
  # Sets the user's invitation.
  #
  def set_invitation
    arel            = Invitation.arel_table
    self.invitation = Invitation.find_by(arel[:email].matches(self.email))
  end
end
