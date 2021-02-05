require 'pokebot/lambda/event'
require 'pokebot/service/interaction'

def handle(event:, context:)
  interaction_event = Pokebot::Lambda::Event.slack_interaction_event(event)
  Pokebot::Service::Interaction.call(interaction_event)
  "hello"
end

