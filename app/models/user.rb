class User < ActiveRecord::Base
  Roles = {
    admin: 'admin',
    merchant: 'merchant',
    reviewer: 'reviewer'
  }

  @@per_page = 10
  cattr_reader :per_page
  mount_uploader :logo, ImageUploader

  has_many :plugins, :class_name => "UserPlugin", :order => "position ASC", :dependent => :destroy
  has_many :transactions, :foreign_key => "client_id"
  has_many :reviewers, :class_name => User, :foreign_key => :merchant_id, :conditions => { :role => User::Roles[:reviewer] }
  has_one :user_setting

  belongs_to :merchant, :class_name => User, :foreign_key => :merchant_id

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :plugins, :terms, :company_name, :company_website, :logo, :logo_cache, :merchant
  # attr_accessible :title, :body
  validates_acceptance_of :terms
  validates :merchant, :presence => {:if => :reviewer?}

  before_save :set_api_key
  after_save :create_user_setting

  delegate :url, :to => :logo, :prefix => true, :allow_nil => true
  delegate :amount_threshold, :to => :user_setting, :prefix => false, :allow_nil => true
  delegate :time_zone, :to => :user_setting, :prefix => false, :allow_nil => true

  scope :invitation_not_accepted, where("invitation_sent_at is not null and invitation_accepted_at is null")
  scope :error_invited, where(error_invited: true)

  Roles.values.each do |role_title|
    define_method "#{role_title}?" do
      self.role == role_title
    end
    scope "#{role_title}".pluralize, conditions: {role: role_title}
  end

  def plugins=(plugin_names)
    if persisted? # don't add plugins when the user_id is nil.
      UserPlugin.delete_all(:user_id => id)
      plugin_names.each_with_index do |plugin_name, index|
        plugins.create(:name => plugin_name, :position => index) if plugin_name.is_a?(String)
      end
    end
  end

  def authorized_plugins
    plugins.collect(&:name) | ::Refinery::Plugins.always_allowed.names
  end

  def add_role(title)
    if Roles.values.include?(title.to_s.downcase)
      self.role = title.to_s.downcase
      save
      self.plugins = Refinery::Plugins.registered.in_menu.names if self.admin?
    end
  end

  def has_role?(title)
    self.role == title.to_s.downcase
  end

  def self.list_of(title)
    case title.to_s.downcase
      when 'pending'
        invitation_not_accepted
      when 'error'
        error_invited
      else
        send(title.to_s.downcase.pluralize)
    end
  end

  def can_access?(other_user)
    self.admin? || self == other_user
  end

  def related_transactions
    if admin?
      Transaction.includes(:note)
    elsif reviewer?
      self.merchant.transactions.includes(:note)
    else
      transactions.includes(:note)
    end
  end

  def can_change_status?(status)
    admin? || merchant? || status != 'reset'
  end

  def available_merchants
    User.merchants - [self]
  end

  def logo_path
    logo_url || "default_avatar.png"
  end

  def fraud_model
    merchant_setting.fraud_model
  end

  private
  def set_api_key
    if self[:api_key].blank?
      self[:api_key] = Digest::SHA1.hexdigest("#{Rails.env}_#{email}")
    end
  end

  def create_user_setting
    self.user_setting = UserSetting.create(user: self, amount_threshold: 0, time_zone: Rails.application.config.time_zone) if self.user_setting.nil?
  end

  def merchant_setting
    self.has_role?("merchant") ? self.user_setting : merchant.user_setting
  end
end
