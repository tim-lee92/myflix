class User < ActiveRecord::Base

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :full_name, presence: true
  validates :password, presence: true

  has_secure_password

  has_many :queue_items
end
