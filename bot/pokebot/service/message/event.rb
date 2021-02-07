require 'pokebot/slack/authentication'
module Pokebot
  module Service
    module Message
      class Event

        def initialize(slack_event)
          @slack_event = slack_event  
        end

        def challenged?
          @slack_event['state']['slack']['challenge']
        end

        def body
          @slack_event['aws_event']['body']
        end

        def slack_request_timestamp
          @slack_event['aws_event']['headers']['x-slack-request-timestamp']
        end

        def slack_signature
          @slack_event['aws_event']['headers']['x-slack-signature']
        end

        def authenticated?
          Pokebot::Slack::Authentication.authenticated?(
            timestamp: slack_request_timestamp,
            signature: slack_signature,
            body: body
          )
        end

        def state
          @slack_event['state']
        end
      end
    end
  end
end
