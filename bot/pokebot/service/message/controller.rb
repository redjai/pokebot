require 'pokebot/topic/sns'
require 'pokebot/lambda/http_response'
require_relative 'event'
require_relative 'search'

module Pokebot
  module Service
    module Message 
      module Controller
        def self.call(slack_event)
          message_event = Pokebot::Service::Message::Event.new(slack_event)

          if message_event.challenged?
             slack_event['http_response'] = Pokebot::Lambda::HttpResponse.plain_text_response(slack_event['state']['slack']['challenge'])
             return
          end
        
          unless message_event.authenticated? 
            slack_event['http_response'] = Pokebot::Lambda::HttpResponse.plain_text('Not authorized', 401)
            return
          end

          Pokebot::Service::Message::Search.call(message_event)
        end
      end
    end
  end
end
