class User < ActiveRecord::Base

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :full_name, presence: true
  validates :password, presence: true

  has_secure_password

  has_many :queue_items, -> { order('position') }

  def normalize_queue_positions
    queue_items.each_with_index do |item, index|
      item.update_attributes(position: index+1)
    end
  end

  def queued_video?(video)
    queue_items.map(&:video).include?(video)
  end
end
