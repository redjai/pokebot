require 'pokebot/topic/sns'
require_relative 'event'

module Pokebot
  module Service
    module Interaction
      module Controller
        extend self

        def call(interaction_event)
          event = Pokebot::Service::Interaction::Event.new(interaction_event)
          event.actions.each do |action|
            if action.favourite?
              event.favourite = action.id 
              Pokebot::Topic::Sns.broadcast(topic: :interactions, event: Pokebot::Lambda::Event::FAVOURITE_NEW, state: event.state)
            end
          end
        end
      end
    end
  end
end
