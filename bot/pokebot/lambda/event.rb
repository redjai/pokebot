module Pokebot
  module Lambda 
    module Event 
      extend self

      MESSAGE_RECEIVED = 'slack-message-received'
      RECIPE_SEARCH_REQUESTED = 'recipes-search-requested'
      FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
      RECIPES_FOUND = 'recipes-found'
      FAVOURITE_NEW = 'favourite-new'
      USER_FAVOURITES_UPDATED = 'user-favourites-updated'

      SLACK_EVENT_API_REQUEST = 'slack-event-api-request'

      require 'json'

      class BotEventRecord
        
        attr_reader :record

        def initialize(source:, name:, version:, data: [])
          @record = { 'name' => name, 
                      'metadata' => 
                         { 'source' => source, 
                           'version' => version, 
                           'ts' => Time.now.to_f },
                      'data' => data }
        end

        def to_h
          @record.to_h
        end

      end

      class BotEvent

        attr_reader :current

        def initialize(current:, trail: [])
          @current = current.to_h
          @trail = trail
        end

        def data
          current['data']
        end

        def name
          current['name']
        end

        def current=(record)
          trail.unshift(@current.to_h)
          @current = record.to_h
        end

        def trail
          @trail ||= []
        end

        def to_json
          { current: @current, trail: @trail }.to_json 
        end
      end
      
      def slack_api_event(aws_event)
        record = BotEventRecord.new(  name: 'slack-event-api-request',
                           source: 'slack-event-api',
                          version: 1.0,
                             data: http_data(aws_event))   
        BotEvent.new current: record
      end

      def slack_interaction_event(aws_event)
        record = BotEventRecord.new(  name: 'slack-interaction-api-request',
                           source: 'slack-interaction-api',
                          version: 1.0,
                             data: payload_data(aws_event))   
        BotEvent.new current: record
      end

      def http_data(aws_event)
        data(aws_event)
      end

      def payload_data(aws_event)
        require 'uri'
        JSON.parse(URI.decode(body(aws_event).gsub(/^payload=/,"")))
      end
      
      def each_sqs_record_bot_event(aws_event:, accept: [])
        aws_event['Records'].each do |aws_record|
          bot_event = sqs_record_bot_event(aws_record)
          puts "Record in:"
          puts bot_event.to_json
          if accept.empty? || accept.include?(bot_event.current['name'])
            yield bot_event
          else
            puts "event #{bot_event['name']} not accepted"
          end
        end
      end

      def sqs_record_bot_event(aws_record)
        event = JSON.parse(data(aws_record)["Message"])
        BotEvent.new current: event['current'], trail: event['trail']
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
