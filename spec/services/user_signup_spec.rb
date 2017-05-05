require 'spec_helper'

describe UserSignup do
  describe '#sign_up' do
    context 'valid personal info and valid card' do
      let(:customer) { double(:customer, successful?: true, customer_token: 'a12345') }

      before do
        expect(StripeWrapper::Customer).to receive(:create).and_return(customer)
      end

      after { ActionMailer::Base.deliveries.clear }

      it 'creates the user' do
        UserSignup.new(Fabricate.build(:user)).sign_up('random stripe token', nil)
        expect(User.count).to eq(1)
      end

      it 'stores the customer token from Stripe' do
        UserSignup.new(Fabricate.build(:user)).sign_up('random stripe token', nil)
        expect(User.first.customer_token).to eq('a12345')
      end

      it 'makes the user follow the inviter' do
        jacky = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jacky, recipient_email: 'example@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'example@example.com')).sign_up('random stripe token', invitation.token)
        user = User.where(email: 'example@example.com').first
        expect(user.follows?(jacky)).to be_truthy
      end

      it 'makes the inviter follow the user' do
        jacky = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jacky, recipient_email: 'example@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'example@example.com')).sign_up('random stripe token', invitation.token)
        user = User.where(email: 'example@example.com').first
        expect(jacky.follows?(user)).to be_truthy
      end

      it 'expires the invitation upon acceptance' do
        jacky = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jacky, recipient_email: 'example@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'example@example.com')).sign_up('random stripe token', invitation.token)
        expect(Invitation.first.token).to be_nil
      end

      it 'sends out email to the user with valid inputs' do
        UserSignup.new(Fabricate.build(:user, email: 'kx@example.com')).sign_up('random stripe token', nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(['kx@example.com'])
      end

      it 'sends out email containing the user\'s name with valid inputs' do
        UserSignup.new(Fabricate.build(:user, full_name: 'Kevin X')).sign_up('random stripe token', nil)
        expect(ActionMailer::Base.deliveries.last.body).to include('Kevin X')
      end
    end

    context 'valid personal info and declined card' do
      let(:customer) { double(:customer, successful?: false, error_message: 'Your card was declined') }
      before { expect(StripeWrapper::Customer).to receive(:create).and_return(customer) }
      after { ActionMailer::Base.deliveries.clear }

      it 'does not create a new user record' do
        UserSignup.new(Fabricate.build(:user)).sign_up('12323132', nil)
        expect(User.count).to eq(0)
      end
    end

    context 'with invalid personal info' do
      before { UserSignup.new(User.new(email: 'jacky@example.com')).sign_up('122', nil) }
      after { ActionMailer::Base.deliveries.clear }

      it 'does not create the user' do
        expect(User.count).to eq(0)
      end

      it 'does not charge the card' do
        expect(StripeWrapper::Charge).not_to receive(:create)
      end

      it 'does not send out email with invalid inputs' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
