class QueueItemsController < ApplicationController
  before_filter :require_user

  def index
    @queue_items = QueueItem.where(user_id: session[:user_id])
    # @queue_items = current_user.queue_items
  end

  def create
    video = Video.find(params[:video_id])
    last_position = current_user.queue_items.count + 1

    if !video_in_queue?(video)
      QueueItem.create(video: video, user: current_user, position: last_position)
    end

    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    queue_item.destroy if current_user.queue_items.include?(queue_item)
    redirect_to my_queue_path
  end

  private

  def video_in_queue?(video)
    current_user.queue_items.map(&:video).include?(video)
  end
end
