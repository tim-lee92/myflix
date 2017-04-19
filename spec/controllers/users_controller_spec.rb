require 'spec_helper'

describe UsersController do
  describe 'GET new' do
    it 'sets @user' do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe 'POST create' do
    context 'successful user sign up' do
      let(:result) { double(:sign_up_result, successful?: true) }
      before { expect_any_instance_of(UserSignup).to receive(:sign_up).and_return(result) }
      # before { UserSignup.any_instance.should_receive(:sign_up).and_return(result) }
      after { ActionMailer::Base.deliveries.clear }

      it 'redirects to the sign in page' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'failed user sign up' do
      let(:result) { double(:sign_up_result, successful?: false, error_message: 'Random message') }
      before { expect_any_instance_of(UserSignup).to receive(:sign_up).and_return(result) }
      # before { UserSignup.any_instance.should_receive(:sign_up).and_return(result) }

      it 'renders the new template' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: 'random_val'
        expect(response).to render_template(:new)
      end

      it 'sets the error message' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: 'random_val'
        expect(flash[:error]).not_to be_nil
      end
    end
  end

  describe 'GET show' do
    it_behaves_like 'requires sign in' do
      let(:action) { get :show, id: 3}
    end

    it 'sets @user' do
      set_current_user
      jacky = Fabricate(:user)
      get :show, id: jacky.id
      expect(assigns(:user)).to eq(jacky)
    end
  end

  describe 'GET new_with_invitation_token' do
    it 'renders the new view template' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template(:new)
    end

    it 'sets @user with recipient\'s email' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end

    it 'sets @invitation_token' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end

    it 'redirects to expired token page for invalid tokens' do
      get :new_with_invitation_token, token: 'random_token'
      expect(response).to redirect_to(expired_token_path)
    end
  end
end
