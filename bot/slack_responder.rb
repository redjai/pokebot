require 'pokebot/lambda/event'

EVENTS = [Pokebot::Lambda::Event::POKEBOT_RESPONSE_RECEIVED]

def handle(event:, context:)
  puts event
  Pokebot::Lambda::Event.each_sqs_record_pokebot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    puts pokebot_event
    require 'pokebot/service/slack_responder'
    Pokebot::Service::SlackResponder.call(pokebot_event)
  end 
end


