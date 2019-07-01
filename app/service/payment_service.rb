module PaymentService
  class << self
    def charge_stripe(order, token)
      begin
        Stripe.api_key = Novelty::Application.config.stripe[:secret_key]

        charge = Stripe::Charge.create(
          amount:      order.total_price,
          currency:    'jpy',
          source:      token,
          description: "[ご注文番号:#{order.id}]"
        )

      #TODO: エラーの種類ごとにメッセージを出し分ける
      # https://stripe.com/docs/api/ruby#error_handling
      rescue Stripe::CardError => e
        # Since it's a decline, Stripe::CardError will be caught
        logger.error e
        raise Exception.new e.class
      rescue Stripe::RateLimitError => e
        # Too many requests made to the API too quickly
        logger.error e
        raise Exception.new e.class
      rescue Stripe::InvalidRequestError => e
        # Invalid parameters were supplied to Stripe's API
        logger.error e
        raise Exception.new e.class
      rescue Stripe::AuthenticationError => e
        # Authentication with Stripe's API failed
        # (maybe you changed API keys recently)
        logger.error e
        raise Exception.new e.class
      rescue Stripe::APIConnectionError => e
        # Network communication with Stripe failed
        logger.error e
        raise Exception.new e.class
      rescue Stripe::StripeError => e
        # Display a very generic error to the user, and maybe send
        # yourself an email
        logger.error e
        raise Exception.new e.class
      rescue => e
        # Something else happened, completely unrelated to Stripe
        logger.error e
        raise Exception.new e.class
      end
    end

  end
end
