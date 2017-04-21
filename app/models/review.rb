class Review < ActiveRecord::Base
  belongs_to :video, touch: true
  belongs_to :user

  validates :content, presence: true
  validates :rating, presence: true
end
