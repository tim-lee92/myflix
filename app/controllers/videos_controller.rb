class VideosController < ApplicationController
  before_action :require_user

  layout 'application'

  def home
    @videos = Video.all
    @categories = Category.all

    render 'videos/index'
  end

  def details
    @video = VideoDecorator.decorate(Video.find(params[:id]))
    @reviews = @video.reviews

    render 'videos/details'
  end

  def search
    @results = Video.search_by_title(params[:search_term])
  end

  def advanced_search
    options = {
      reviews: params[:reviews],
      rating_from: params[:rating_from],
      rating_to: params[:rating_to]
    }

    if params[:query]
      @videos = Video.search(params[:query], options).records.to_a
    else
      @videos = []
    end
  end
end
