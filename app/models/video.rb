class Video < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks  #Add ActiveRecord callbacks on the models to automatically send to Elasticsearch

  index_name ['myflix', Rails.env].join('-')

  belongs_to :category
  has_many :reviews, -> { order("created_at DESC")}

  mount_uploader :large_cover, LargeCoverUploader
  mount_uploader :small_cover, SmallCoverUploader

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

  def rating
    total_score = 0
    reviews.each do |review|
      total_score += review.rating
    end

    (total_score.to_f / reviews.count).round(2)
  end

  def self.search(query, options={})
    search_definition = {
      query: {
        bool: {
          must: {
            multi_match: {
              query: query,
              fields: ['title^100', 'description^50'],
              operator: 'and'
            }
          }
        }
      }
    }

    if query.present? && options[:reviews].present?
      search_definition[:query][:bool][:must][:multi_match][:fields] << 'reviews.content'
    end

    if options[:rating_from].present? || options[:rating_to].present?
      search_definition[:query][:bool][:filter] = {
        range: {
          rating: {
            gte: (options[:rating_from] if options[:rating_from].present?),
            lte: (options[:rating_to] if options[:rating_to].present?)
          }
        }
      }
    end

    __elasticsearch__.search(search_definition)
  end

  def as_indexed_json(options={})
    as_json(
      methods: [:rating],
      only: [:title, :description],
      include: {
        reviews: { only: [:content] }
      }
    )
  end
end
