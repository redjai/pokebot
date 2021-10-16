module Gerty
  module Listeners
    module Http
      module Authentication
        extend self

        def authenticated?(timestamp:, signature:, body:)
          calculated_signature(timestamp, body) == signature
        end

        private
        
        def calculated_signature(timestamp, body)
          "v0=#{hexdigest(timestamp, body)}"
        end
        
        def hexdigest(timestamp, body)
          OpenSSL::HMAC.hexdigest(
            "SHA256", 
            ENV['SLACK_SIGNED_SECRET'], 
            base(timestamp, body)
          )
        end
        
        def base(timestamp, body)
          "v0:#{timestamp}:#{body}"
        end

      end
    end
  end
end
