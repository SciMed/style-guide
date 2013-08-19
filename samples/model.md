```Ruby
class User < ActiveRecord::Base
  extend Auditable
  include Emailable

  set_table_name :people
  set_primary_key :uid

  default_scope { where(active: true) }

  has_attachment :document, resize_to_fit: true
  can_login, memorable: true

  GENDERS = %w(male female)

  attr_accessible :login, :first_name, :last_name, :email, :password

  before_save :cook
  after_save :update_username_lower

  validate :within_time_period
  validate :currently_active_member

  validates :email, presence: true
  validates :password, format: { with: /\A\S{8,128}\z/, allow_nil: true}
  validates :username, presence: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, format: { with: /\A[A-Za-z][A-Za-z0-9._-]{2,19}\z/ }

  attr_accessor :formatted_date_of_birth

  delegate :treats, to: :dog

  belongs_to :country
  belongs_to :city
  belongs_to :state

  has_and_belongs_to_many # DISCOURAGED

  has_many :authentications
  has_many :comments
  has_many :posts

  has_one :address

  accepts_nested_attributes_for :comments

  scope :administrators, -> { where(admin: true) }
  scope :active, -> { where(active: true) }

  def self.trim_inactive
    # ...
  end

  def calculate_age
    # ...
  end

  private

    def self.some
      # ...
    end

    def whatevs
      # ...
    end

end
```