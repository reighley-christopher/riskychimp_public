class Note < ActiveRecord::Base
  belongs_to :transaction
  attr_accessible :transaction, :content

  validates :transaction, presence: true
  validates :content, presence: true
end
