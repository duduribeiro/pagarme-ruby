require_relative '../../test_helper'
require 'json'

module PagarMe
  class TransactionTest < PagarMeTestCase
    should 'be valid when has valid signature' do
      fixed_api_key do
        postback = PagarMe::Postback.new postback_response_params
        assert postback.valid?
      end
    end

    should 'be valid when has invalid signature' do
      postback = PagarMe::Postback.new postback_response_params(signature: 'sha1=invalid signature')
      assert !postback.valid?
    end

    should 'validate signature' do
      fixed_api_key do
        params = postback_response_params
        assert  PagarMe::Postback.valid_request_signature?(params[:payload], params[:signature])
        assert !PagarMe::Postback.valid_request_signature?(params[:payload], params[:signature][4..-1])
        assert !PagarMe::Postback.valid_request_signature?(params[:payload], 'invalid signature')
      end
    end

    should 'redeliver a transaction postback' do
      transaction = PagarMe::Transaction.create transaction_with_customer_with_card_with_postback_params
      postback = transaction.postbacks.last
      redeliver = postback.redeliver

      assert_equal redeliver["status"], 'pending_retry'

    end
  end
end
