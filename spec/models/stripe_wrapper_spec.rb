require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe '.create' do
      it 'makes a successful charge', :vcr do
        token = Stripe::Token.create(
          card: {
            number: '4242424242424242',
            exp_month: 6,
            exp_year: 2020,
            cvc: 314
          }
        ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: 'a valid charge'
        )

        # expect(response.amount).to eq(999)
        # expect(response.currency).to eq('usd')
        expect(response.successful?).to be_truthy
      end

      it 'makes a card declined charge', :vcr do
        token = Stripe::Token.create(
          card: {
            number: '4000000000000002',
            exp_month: 6,
            exp_year: 2020,
            cvc: 314
          }
        ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: 'a valid charge'
        )

        expect(response.successful?).to be_falsey
      end

      it 'returns the error message for declined charges', :vcr do
        token = Stripe::Token.create(
          card: {
            number: '4000000000000002',
            exp_month: 6,
            exp_year: 2020,
            cvc: 314
          }
        ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: 'a valid charge'
        )

        expect(response.error_message).to eq('Your card was declined.')
      end
    end
  end
end
