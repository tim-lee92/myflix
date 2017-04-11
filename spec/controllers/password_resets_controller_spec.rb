require 'spec_helper'

describe PasswordResetsController do
  it 'renders the template if the token is valid' do
    lily = Fabricate(:user)
    lily.update_column(:token, '12345')
    get :show, id: '12345'
    expect(response).to render_template(:show)
  end

  it 'sets @token' do
    lily = Fabricate(:user)
    lily.update_column(:token, '12345')
    get :show, id: '12345'
    expect(assigns(:token)).to eq('12345')
  end

  it 'redirects to the expired token page if token is valid' do
    get :show, id: '12345'
    expect(response).to redirect_to(expired_token_path)
  end

  describe 'POST create' do
    context "with valid token" do
      it 'redirects to the sign in page' do
        lily = Fabricate(:user, password: 'old_password')
        lily.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(response).to redirect_to(sign_in_path)
      end

      it 'updates the user\'s password' do
        lily = Fabricate(:user, password: 'old_password')
        lily.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(lily.reload.authenticate('new_password')).to be_truthy
      end

      it 'sets the flash success message' do
        lily = Fabricate(:user, password: 'old_password')
        lily.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(flash[:success]).to be_present
      end

      it 'regenerates the user token' do
        lily = Fabricate(:user, password: 'old_password')
        lily.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(lily.reload.token).not_to eq('12345')
      end
    end

    context "with invalid token" do
      it 'redirects to the expired token path' do
        post :create, token: '12345', password: 'random_password'
        expect(response).to redirect_to(expired_token_path)
      end
    end
  end
end
