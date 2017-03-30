class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order("created_at DESC")}

  validates :title, presence: true, uniqueness: {case_sensitive: false}
  validates :description, presence: true

  def self.search_by_title(string)
    return [] if string.blank?
    result = where('title LIKE ?', "%#{string}%").order('created_at DESC')
    if result == []
      result = where('title LIKE ?', "%#{string.capitalize}%").order('created_at DESC')
      if result == []
        result = where('title LIKE ?', "%#{string.downcase}%").order('created_at DESC')
      end
    end

    result
  end
end
