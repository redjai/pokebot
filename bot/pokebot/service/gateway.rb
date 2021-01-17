require 'pokebot/topic/sns'
require 'pokebot/lambda/http_response'
require 'pokebot/slack/authentication'

module Pokebot
  module Service
    module Gateway
      def self.call(slack_event)

        if slack_event['state']['slack']['challenge']
           slack_event['http_response'] = Pokebot::Lambda::HttpResponse.plain_text_response(slack_event['state']['slack']['challenge'])
           puts "challenge"
           return
        end
       
        unless Pokebot::Slack::Authentication.authenticated?(
                 timestamp: slack_event['aws_event']['headers']['x-slack-request-timestamp'],
                 signature: slack_event['aws_event']['headers']['x-slack-signature'],
                 body: slack_event['aws_event']['body']
              )
          slack_event['http_response'] = Pokebot::Lambda::HttpResponse.plain_text('Not authorized', 401)
          puts "401"
          return
        end
        
        Pokebot::Topic::Sns.broadcast(
          topic: :messages, 
          event: Pokebot::Lambda::Event::MESSAGE_RECEIVED, 
          state: slack_event['state']
        )

      end
    end
  end
end
