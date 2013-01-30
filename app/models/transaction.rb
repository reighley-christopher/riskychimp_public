class Transaction < ActiveRecord::Base
  LEARNING_SIZE = 500

  has_paper_trail :on => [:update], :only => [:status]
  @@per_page = 10
  cattr_reader :per_page
  belongs_to :user, :foreign_key => "client_id"
  has_one :note
  has_many :related_transactions, :class_name => Transaction,
           :finder_sql => Proc.new {
             %Q{select * from transactions
                where (purchaser_id = '#{purchaser_id}' or device_id = '#{device_id}')
                and id != #{id} and client_id = #{client_id.to_i}}
           }
  attr_accessible :amount, :client_id, :email, :ip, :name, :other_data, :purchaser_id, :shipping_city,
                  :shipping_country, :shipping_state, :shipping_zip, :transaction_id, :device_id,
                  :transaction_datetime, :unparsed_transaction_datetime, :transaction_datetime_offset
  delegate :email, :to => :user, :prefix => true, :allow_nil => true
  delegate :email, :to => :reviewer, :prefix => true, :allow_nil => true

  scope :for_learn, limit(LEARNING_SIZE)

  def self.find_public_ips
    #TODO this will get called often.  It needs to be cached somehow.
    Transaction.all( :group => :ip, :having => "count(*) > 1 and count(distinct email) > 1" ).map{|trans| trans.ip}
  end

  scope :date_from, (lambda do |from|
    raise Error if ![DateTime, Time, ActiveSupport::TimeWithZone, NilClass].include? from.class
    where('transaction_datetime >= ?', from) if from.present?
  end)
  scope :amount_from, lambda {|from| where('amount >= ?', from) if from.present? && from.to_f > 0}
  scope :with_email, lambda {|email| where(email: email)}

  def calculate_score!
    user.fraud_model.reliability_score(self).tap do |s|
      self.score = s
      self.save
    end
  end

  def self.available_attrs
    new.attributes.keys - Transaction.protected_attributes.to_a
  end

  state_machine :status, :initial => :pending do
    state :pending
    state :holding
    state :approved
    state :rejected

    event :hold do
      transition :pending => :holding
    end

    event :approve do
      transition :pending => :approved
    end

    event :reject do
      transition :pending => :rejected
    end

    event :reset do
      transition all => :pending
    end
  end

  def other_data
    return @other_data if @other_data
    data = read_attribute(:other_data)
    begin
      begin
        if data[0] == '{'
          @other_data = JSON.parse(data).with_indifferent_access
        else @other_data = YAML.load(data) end
      rescue
        @other_data = YAML.load(data)
      end
    rescue
      #if deserialization fails, we still want to ensure that we return a HashWithIndifferentAccess
      @other_data = { "" => self[:other_data] }.with_indifferent_access
    end
    ensure_other_data
    @other_data
  end

  def other_data=(value)
    begin
      r_value = value
      value = YAML.load(value) if value.class == String
    rescue Exception
      #here we have completely failed to deserialize, store the value as the raw string under the nil key
      value = HashWithIndifferentAccess.new("" => r_value)
    end
    #here we have deserialized, but as a Hash which is not quite what we want, so we cast it
    value = value.with_indifferent_access if value.class == Hash
    #by this point we should have a HashWithIndifferentAccess. If not something is wrong, so we file under nil key.
    value = HashWithIndifferentAccess.new("" => value) unless value.class == HashWithIndifferentAccess
    @other_data.__set_transaction(nil) if @other_data
    @other_data = value
    ensure_other_data
    write_attribute(:other_data, value.to_json)
  end

  def related_notes
    Note.where(transaction_id: related_transaction_ids)
  end

  def reviewer
    pending? ? nil : User.where(id: versions.last.try(:whodunnit)).first
  end

  private

  #changes to other_data should update other_data in the transaction
  def ensure_other_data
    class << @other_data
      def __set_transaction(tr)
        @transaction = tr
      end

      def []=(key, value)
        super(key, value)
        @transaction.other_data = self if @transaction
      end
    end
    @other_data.__set_transaction(self)
  end
end
