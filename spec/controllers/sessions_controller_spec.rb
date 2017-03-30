require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    it 'renders the new template for unauthenticated users' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'redirects to the home page for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to(home_path)
    end
  end

  describe 'POST create' do
    context 'with valid credentials' do
      let(:jacky) do
        Fabricate(:user)
      end

      before do
        post :create, {email: jacky.email, password: jacky.password}
      end

      it 'puts the signed in user in the session' do
        expect(session[:user_id]).to eq(jacky.id)
      end

      it 'redirects to the home path' do
        expect(response).to redirect_to(home_path)
      end

      it 'sets the notice' do
        expect(flash[:notice]).not_to be_blank
      end
    end

    context 'with invalid credentials' do
      let(:richard) do
        Fabricate(:user)
      end

      before do
        post :create, { email: richard.email, password: richard.email + '12' }
      end

      it 'does not put a user in the session' do
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(sign_in_path)
      end

      it 'sets the error message' do
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe "GET destroy" do
    before do
      session[:user_id] = Fabricate(:user).id
    end

    it 'clears the session for the user' do
      get :destroy
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the root path' do
      get :destroy
      expect(response).to redirect_to(root_path)
    end

    it 'sets the notice' do
      get :destroy
      expect(flash[:notice]).not_to be_blank
    end
  end
end
