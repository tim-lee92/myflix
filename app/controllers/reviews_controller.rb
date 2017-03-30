class ReviewsController < ApplicationController
  before_filter :require_user
  def create
    @video = Video.find(params[:video_id])
    review = @video.reviews.build(params.require(:review).permit!.merge!(user: current_user))
    # Review.create(params.require(:review).permit!)
    if review.save
      redirect_to "/videos/#{params[:video_id]}"
    else
      @reviews = @video.reviews.reload
      render 'videos/details'
    end
    # redirect_to video_path
  end
end
