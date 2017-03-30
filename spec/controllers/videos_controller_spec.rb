require 'spec_helper'

describe VideosController do
  describe "GET show" do
    context "with authenticated users" do
      before do
        session[:user_id] = Fabricate(:user).id
      end

      it "sets @video" do
        video = Fabricate(:video)
        get :details, id: video.id
        expect(assigns(:video)).to eq(video)
      end

      it 'sets @reviews' do
        video = Fabricate(:video)
        review1 = Fabricate(:review, video: video)
        review2 = Fabricate(:review, video: video)
        get :details, id: video.id
        # assigns(:reviews).should =~ [review1, review2]
        expect(assigns(:reviews)).to match_array([review1, review2])
      end
    end

    context "with unautherticated users" do
      it "redirects the user to the sign in page" do
        video = Fabricate(:video)
        get :details, id: video.id
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe "GET search" do
    context "with authenticated users" do
      before do
        session[:user_id] = Fabricate(:user).id
      end

      it "sets @results" do
        colbert = Fabricate(:video, title: "Tonight show with Steven Colbert")
        post :search, search_term: 'ber'
        expect(assigns(:results)).to eq([colbert])
      end
    end

    context "with unauthenticated users" do
      it "redirects the user to sign in page" do
        session[:user_id] = nil
        colbert = Fabricate(:video, title: "Tonight show with Steven Colbert")
        post :search, search_term: 'anything'
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

end
