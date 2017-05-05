require 'spec_helper'

describe 'Deactivate user on failed charge' do
  let(:event_data) do
    {
      "id" => "evt_1AAYOjDKhR7Awq4Yq76CIfy5",
      "object" => "event",
      "api_version" => "2017-04-06",
      "created" => 1492668249,
      "data" => {
        "object" => {
          "id" => "ch_1AAYOjDKhR7Awq4YnI5Uy7VO",
          "object" => "charge",
          "amount" => 999,
          "amount_refunded" => 0,
          "application" => nil,
          "application_fee" => nil,
          "balance_transaction" => nil,
          "captured" => false,
          "created" => 1492668249,
          "currency" => "usd",
          "customer" => "cus_AVXvmGnAzdVB4O",
          "description" => "Stuff",
          "destination" => nil,
          "dispute" => nil,
          "failure_code" => "card_declined",
          "failure_message" => "Your card was declined.",
          "fraud_details" => {
          },
          "invoice" => nil,
          "livemode" => false,
          "metadata" => {
          },
          "on_behalf_of" => nil,
          "order" => nil,
          "outcome" => {
            "network_status" => "declined_by_network",
            "reason" => "generic_decline",
            "risk_level" => "normal",
            "seller_message" => "The bank did not return any further details with this decline.",
            "type" => "issuer_declined"
          },
          "paid" => false,
          "receipt_email" => nil,
          "receipt_number" => nil,
          "refunded" => false,
          "refunds" => {
            "object" => "list",
            "data" => [
            ],
            "has_more" => false,
            "total_count" => 0,
            "url" => "/v1/charges/ch_1AAYOjDKhR7Awq4YnI5Uy7VO/refunds"
          },
          "review" => nil,
          "shipping" => nil,
          "source" => {
            "id" => "card_1AAYO2DKhR7Awq4YGrybQn3p",
            "object" => "card",
            "address_city" => nil,
            "address_country" => nil,
            "address_line1" => nil,
            "address_line1_check" => nil,
            "address_line2" => nil,
            "address_state" => nil,
            "address_zip" => nil,
            "address_zip_check" => nil,
            "brand" => "Visa",
            "country" => "US",
            "customer" => "cus_AVXvmGnAzdVB4O",
            "cvc_check" => "pass",
            "dynamic_last4" => nil,
            "exp_month" => 4,
            "exp_year" => 2025,
            "fingerprint" => "q89ocJTd0GAuyJIO",
            "funding" => "credit",
            "last4" => "0341",
            "metadata" => {
            },
            "name" => nil,
            "tokenization_method" => nil
          },
          "source_transfer" => nil,
          "statement_descriptor" => nil,
          "status" => "failed",
          "transfer_group" => nil
        }
      },
      "livemode" => false,
      "pending_webhooks" => 1,
      "request" => "req_AVZXXRcAXJjwdd",
      "type" => "charge.failed"
    }
  end

  it 'deactivates a user with the web hook data from Stripe for a charge failed', :vcr do
    lily = Fabricate(:user, customer_token: 'cus_AVXvmGnAzdVB4O')
    post '/stripe_events', event_data
    expect(lily.reload).not_to be_active
  end
end
