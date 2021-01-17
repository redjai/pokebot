require 'pokebot/lambda/event'
require 'pokebot/service/gateway'

def handle(event:, context:)
  puts Pokebot::Lambda::Event.payload_data(event)
end

