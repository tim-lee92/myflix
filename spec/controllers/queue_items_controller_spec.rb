require 'spec_helper'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the logged in user' do
      lily = Fabricate(:user)
      session[:user_id] = lily.id
      queue_item1 = Fabricate(:queue_item, user: lily)
      queue_item2 = Fabricate(:queue_item, user: lily)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it 'redirects to the sign in page for unauthenticated users' do
      get :index
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe "POST create" do
    let(:video) { Fabricate(:video) }

    it 'redirects to the "my queue" page' do
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it 'creates a queue item' do
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it 'creates the queue item that is associated with the video' do
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it 'creates the queue item that is associated with the signed-in use' do
      richard = Fabricate(:user)
      session[:user_id] = richard.id
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(richard)
    end

    it 'puts the video as the last one in the queue' do
      richard = Fabricate(:user)
      session[:user_id] = richard.id
      bbt = Fabricate(:queue_item, video: bbt, user: richard)
      hk = Fabricate(:video)
      post :create, video_id: hk.id
      hk_queue_item = QueueItem.where(video_id: hk.id, user_id: richard.id).first
      expect(hk_queue_item.position).to eq(2)
    end

    it 'does not add the video to the queue if the video is already in the queue' do
      richard = Fabricate(:user)
      session[:user_id] = richard.id
      hk = Fabricate(:video)
      Fabricate(:queue_item, video: hk, user: richard)
      post :create, video_id: hk.id
      expect(richard.queue_items.count).to eq(1)
    end

    it 'redirects to the sign-in page for unauthenticated users' do
      post :create, video_id: video.id
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe 'DELETE destroy' do
    it 'redirects to the "my queue" page' do
      john = Fabricate(:user)
      session[:user_id] = john.id
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to(my_queue_path)
    end

    it 'deletes the queue item' do
      john = Fabricate(:user)
      session[:user_id] = john.id
      queue_item = Fabricate(:queue_item, user: john)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it 'does not delete the queue item if the current user does not own that queue item' do
      kevin = Fabricate(:user)
      jacky = Fabricate(:user)
      session[:user_id] = kevin.id
      queue_item = Fabricate(:queue_item, user: jacky)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq (1)
    end

    it 'redirects to the sign in page for unauthenticated users' do
      delete :destroy, id: 1
      expect(response).to redirect_to(sign_in_path)
    end
  end
end
