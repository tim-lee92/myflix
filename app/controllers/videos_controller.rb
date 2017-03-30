class VideosController < ApplicationController
  before_action :require_user

  layout 'application'

  def home
    @videos = Video.all
    @categories = Category.all

    render 'videos/index'
  end

  def details
    @video = Video.find(params[:id])
    @reviews = @video.reviews

    render 'videos/details'
  end

  def search
    @results = Video.search_by_title(params[:search_term])
  end
end
