require 'spec_helper'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the logged in user' do
      lily = Fabricate(:user)
      set_current_user(lily)
      queue_item1 = Fabricate(:queue_item, user: lily)
      queue_item2 = Fabricate(:queue_item, user: lily)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    # it 'redirects to the sign in page for unauthenticated users' do
    #   get :index
    #   expect(response).to redirect_to(sign_in_path)
    # end

    it_behaves_like 'requires sign in' do
      let(:action) { get :index }
    end
  end

  describe "POST create" do
    let(:video) { Fabricate(:video) }
    before do
      set_current_user
    end

    it 'redirects to the "my queue" page' do
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it 'creates a queue item' do
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it 'creates the queue item that is associated with the video' do
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it 'creates the queue item that is associated with the signed-in use' do
      richard = Fabricate(:user)
      set_current_user(richard)
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(richard)
    end

    it 'puts the video as the last one in the queue' do
      richard = Fabricate(:user)
      set_current_user(richard)
      bbt = Fabricate(:queue_item, video: bbt, user: richard)
      hk = Fabricate(:video)
      post :create, video_id: hk.id
      hk_queue_item = QueueItem.where(video_id: hk.id, user_id: richard.id).first
      expect(hk_queue_item.position).to eq(2)
    end

    it 'does not add the video to the queue if the video is already in the queue' do
      richard = Fabricate(:user)
      set_current_user(richard)
      hk = Fabricate(:video)
      Fabricate(:queue_item, video: hk, user: richard)
      post :create, video_id: hk.id
      expect(richard.queue_items.count).to eq(1)
    end

    # it 'redirects to the sign-in page for unauthenticated users' do
    #   session[:user_id] = nil
    #   post :create, video_id: video.id
    #   expect(response).to redirect_to(sign_in_path)
    # end

    it_behaves_like 'requires sign in' do
      let(:action) { post :create, video_id: video.id }
    end
  end

  describe 'DELETE destroy' do
    it 'redirects to the "my queue" page' do
      john = Fabricate(:user)
      set_current_user(john)
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to(my_queue_path)
    end

    it 'deletes the queue item' do
      john = Fabricate(:user)
      set_current_user(john)
      queue_item = Fabricate(:queue_item, user: john)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it 'normalizes the remaining queue items' do
      john = Fabricate(:user)
      set_current_user(john)
      queue_item1 = Fabricate(:queue_item, user: john, position: 1)
      queue_item2 = Fabricate(:queue_item, user: john, position: 2)
      delete :destroy, id: queue_item1.id
      expect(queue_item2.reload.position).to eq(1)
    end

    it 'does not delete the queue item if the current user does not own that queue item' do
      kevin = Fabricate(:user)
      jacky = Fabricate(:user)
      set_current_user(kevin)
      queue_item = Fabricate(:queue_item, user: jacky)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq (1)
    end

    # it 'redirects to the sign in page for unauthenticated users' do
    #   delete :destroy, id: 1
    #   expect(response).to redirect_to(sign_in_path)
    # end

    it_behaves_like 'requires sign in' do
      let(:action) { delete :destroy, id: 1 }
    end
  end

  describe 'POST update_queue' do
    context 'with valid inputs' do
      let(:timmy) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: timmy, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: timmy, position: 2, video: video) }

      before do
        set_current_user(timmy)
      end

      it 'redirects to the my queue page' do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(response).to redirect_to my_queue_path
      end

      it 'reorders the queue items' do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(timmy.queue_items).to eq([queue_item2, queue_item1])
      end

      it 'normalizes the position numbers' do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3}]
        expect(timmy.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context 'with invalid inputs' do
      let(:timmy) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: timmy, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: timmy, position: 2, video: video) }

      before do
        set_current_user(timmy)
      end

      it 'redirects to the my queue page' do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2.4}, {id: queue_item2.id, position: 3}]
        expect(response).to redirect_to(my_queue_path)
      end

      it 'sets the flash error message' do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2.4}, {id: queue_item2.id, position: 3}]
        expect(flash[:error]).to be_present
      end

      it 'does not change the queue item' do
        post :update_queue, queue_items: [{id: queue_item1, position: 3}, {id: queue_item2, position: 2.2}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end

    # context 'with unauthenticated users' do
    #   let(:timmy) { Fabricate(:user) }
    #   let(:queue_item1) { Fabricate(:queue_item, user: timmy, position: 1) }
    #   let(:queue_item2) { Fabricate(:queue_item, user: timmy, position: 2) }
    #
    #   it 'redirects to the sign in path' do
    #     post :update_queue, queue_items: [{id: queue_item1, position: 2}, {id: queue_item2, position: 3}]
    #     expect(response).to redirect_to(sign_in_path)
    #   end
    # end

    it_behaves_like 'requires sign in' do
      let(:action) do
        post :update_queue, queue_items: [{id: 2, position: 2}, {id: 10, position: 3}]
      end
    end

    context 'with queue items that do not belong to the current user' do
      let(:timmy) { Fabricate(:user) }
      let(:richard) { Fabricate(:user) }
      let(:queue_item1) { Fabricate(:queue_item, user: timmy, position: 1) }
      let(:queue_item2) { Fabricate(:queue_item, user: timmy, position: 2) }

      it 'does not change the queue items' do
        set_current_user(richard)
        post :update_queue, queue_items: [{id: queue_item1, position: 3}, {id: queue_item2, position: 4}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end
  end
end
