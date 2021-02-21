require 'lambda/event'
require 'service/interaction/controller'

def handle(event:, context:)
  interaction_event = Lambda::Event.slack_interaction_event(event)
  Service::Interaction::Controller.call(interaction_event)
  "hello"
end

