require 'spec_helper'

describe ForgotPasswordsController do
  describe 'POST create' do
    context 'with blank input' do
      it 'redirects to the forgot password page' do
        post :create, email: ''
        expect(response).to redirect_to(forgot_passwords_path)
      end

      it 'shows an error message' do
        post :create, email: ''
        expect(flash[:error]).not_to be_nil
      end
    end

    context 'with existing email' do
      after { ActionMailer::Base.deliveries.clear }
      it 'redirect to to the forgot password confirmation page' do
        Fabricate(:user, email: 'kx@example.com')
        post :create, email: 'kx@example.com'
        expect(response).to redirect_to(forgot_password_confirmation_path)
      end

      it 'sends out an email to the email address' do
        Fabricate(:user, email: 'kx@example.com')
        post :create, email: 'kx@example.com'
        expect(ActionMailer::Base.deliveries.last.to).to eq(['kx@example.com'])
      end
    end

    context 'with non-existing email' do
      it 'redirects to the forgot password page' do
        post :create, email: 'foo@example.com'
        expect(response).to redirect_to(forgot_passwords_path)
      end

      it 'shows an error message' do
        post :create, email: 'foo@example.com'
        expect(flash[:error]).to eq('There is no user with that email in the system.')
      end
    end
  end
end
