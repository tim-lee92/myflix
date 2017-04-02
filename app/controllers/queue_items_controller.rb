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
    current_user.normalize_queue_positions
    redirect_to my_queue_path
  end

  def update_queue
    begin
      update_queue_items
      current_user.normalize_queue_positions
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Invalid position numbers."
    end

    redirect_to my_queue_path
  end

  private

  def video_in_queue?(video)
    current_user.queue_items.map(&:video).include?(video)
  end

  def update_queue_items
    ActiveRecord::Base.transaction do
      params[:queue_items].each do |data|
        queue_item = QueueItem.find(data['id'])
        queue_item.update_attributes!(position: data['position'], rating: data['rating']) if queue_item.user == current_user
      end
    end
  end
end
