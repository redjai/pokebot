module Pokebot
  module Lambda 
    module Event 
      extend self

      MESSAGE_RECEIVED = 'slack-message-received'
      RECIPE_SEARCH_REQUESTED = 'recipes-search-requested'
      RECIPES_FOUND = 'recipes-found'
      FAVOURITE_NEW = 'favourite-new'
      FAVOURITE_CREATED = 'favourite-created'

      def slack_api_event(aws_event)
        { 
          'type' => 'slack_event_api_request',
          'state' => {
            'slack' => http_data(aws_event)
          },
          'aws_event' => aws_event
        }
      end

      def slack_interaction_event(aws_event)
        { 
          'type' => 'slack_event_interaction',
          'state' => {
            'slack' => { 'interaction' => payload_data(aws_event) }
          },
          'aws_event' => aws_event
        }
      end

      def http_data(aws_event)
        data(aws_event)
      end

      def payload_data(aws_event)
        require 'uri'
        JSON.parse(URI.decode(body(aws_event).gsub(/^payload=/,"")))
      end
      
      def each_sqs_record_pokebot_event(aws_event:, accept: [])
        aws_event['Records'].each do |aws_record|
          pokebot_event = sqs_record_pokebot_event(aws_record)
          if accept.empty? || accept.include?(pokebot_event['event'])
            yield pokebot_event
          else
            puts "event #{pokebot_event['event']} not accepted"
          end
        end
      end

      def sqs_record_pokebot_event(aws_record)
        JSON.parse(data(aws_record)["Message"])
      end

      private

      def data(aws_event)
        JSON.parse(body(aws_event))
      end

      def body(aws_event)
        if aws_event["isBase64Encoded"]
          require 'base64'
          Base64.decode64(aws_event['body'])
        else
          aws_event['body']
        end
      end
    end
  end
end
