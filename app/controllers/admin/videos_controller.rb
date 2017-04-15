class Admin::VideosController < ApplicationController
  before_action :require_user
  before_action :require_admin

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params.require(:video).permit(:title, :description, :category_id, :small_cover, :large_cover, :video_url))
    if @video.save
      flash[:success] = 'You have successfully added a new video'
      redirect_to new_admin_video_path
    else
      flash[:error] = 'Please check your inputs'
      render :new
    end
  end

  private

  def require_admin
    if !current_user.admin?
      flash[:error] = 'You do not have the correct permissions.'
      redirect_to home_path
    end
  end
end
