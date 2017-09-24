class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def remember
    self.remember_token = User.create_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    self.remember_token = nil
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.create_token
    self.update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.where('user_id = ?', id)
  end

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def create_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  def downcase_email
    self.email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.create_token
    self.activation_digest = User.digest(activation_token)
  end
end
