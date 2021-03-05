require 'bot/event'
require 'lambda/event'

EVENTS = [Bot::USER_FAVOURITE_NEW] 

def handle(event:, context:)
  Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    require 'service/user/controller'
    Service::User::Controller.call(pokebot_event)
  end 
end
