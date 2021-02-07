require 'pokebot/lambda/event'
require 'pokebot/service/interaction/controller'

def handle(event:, context:)
  interaction_event = Pokebot::Lambda::Event.slack_interaction_event(event)
  Pokebot::Service::Interaction::Controller.call(interaction_event)
  "hello"
end

