require 'spec_helper'

describe 'Create payment on successful charge' do
  let(:event_data) {
    {
      "id" => "evt_1AAVZ6DKhR7Awq4YNMbvqdmd",
      "object" => "event",
      "api_version" => "2017-04-06",
      "created" => 1492657360,
      "data" => {
        "object" => {
          "id" => "ch_1AAVZ5DKhR7Awq4Yp7wqVhQe",
          "object" => "charge",
          "amount" => 999,
          "amount_refunded" => 0,
          "application" => nil,
          "application_fee" => nil,
          "balance_transaction" => "txn_1AAVZ5DKhR7Awq4YaHW7LwGd",
          "captured" => true,
          "created" => 1492657359,
          "currency" => "usd",
          "customer" => "cus_AVWcpB9hZGT8H2",
          "description" => nil,
          "destination" => nil,
          "dispute" => nil,
          "failure_code" => nil,
          "failure_message" => nil,
          "fraud_details" => {
          },
          "invoice" => "in_1AAVZ5DKhR7Awq4Y8eCT2hSc",
          "livemode" => false,
          "metadata" => {
          },
          "on_behalf_of" => nil,
          "order" => nil,
          "outcome" => {
            "network_status" => "approved_by_network",
            "reason" => nil,
            "risk_level" => "normal",
            "seller_message" => "Payment complete.",
            "type" => "authorized"
          },
          "paid" => true,
          "receipt_email" => nil,
          "receipt_number" => nil,
          "refunded" => false,
          "refunds" => {
            "object" => "list",
            "data" => [
            ],
            "has_more" => false,
            "total_count" => 0,
            "url" => "/v1/charges/ch_1AAVZ5DKhR7Awq4Yp7wqVhQe/refunds"
          },
          "review" => nil,
          "shipping" => nil,
          "source" => {
            "id" => "card_1AAVZ4DKhR7Awq4YpO2xTHGy",
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
            "customer" => "cus_AVWcpB9hZGT8H2",
            "cvc_check" => "pass",
            "dynamic_last4" => nil,
            "exp_month" => 10,
            "exp_year" => 2017,
            "fingerprint" => "8QwtImsIuKVbuAeR",
            "funding" => "credit",
            "last4" => "4242",
            "metadata" => {
            },
            "name" => nil,
            "tokenization_method" => nil
          },
          "source_transfer" => nil,
          "statement_descriptor" => nil,
          "status" => "succeeded",
          "transfer_group" => nil
        }
      },
      "livemode" => false,
      "pending_webhooks" => 1,
      "request" => "req_AVWcc4vTzHGbLL",
      "type" => "charge.succeeded"
    }
  }

  it 'creates a payment with the webhook from stripe for charge succeeded', :vcr do
    post '/stripe_events', event_data
    expect(Payment.count).to eq(1)
  end

  it 'creates the payment associated with the user', :vcr do
    richard = Fabricate(:user, customer_token: 'cus_AVWcpB9hZGT8H2')
    post '/stripe_events', event_data
    expect(Payment.first.user).to eq(richard)
  end

  it 'creates the payment with the amount', :vcr do
    richard = Fabricate(:user, customer_token: 'cus_AVWcpB9hZGT8H2')
    post '/stripe_events', event_data
    expect(Payment.first.amount).to eq(999)
  end

  it 'creates the payment with reference id', :vcr do
    richard = Fabricate(:user, customer_token: 'cus_AVWcpB9hZGT8H2')
    post '/stripe_events', event_data
    expect(Payment.first.reference_id).to eq('ch_1AAVZ5DKhR7Awq4Yp7wqVhQe')
  end
end
