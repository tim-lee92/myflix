class VideoDecorator < Draper::Decorator
  delegate_all

  def rating
    if object.reviews.present?
      "#{object.rating}/5.0"
    else
      'N/A'
    end
  end
end
