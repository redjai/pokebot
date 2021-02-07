require 'pokebot/topic/sns'

module Pokebot
  module Service
    module Interaction
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

      def favourite(user_id, recipe_id)
        @@resource.client.update_item({
          key: {
            "user_id" => user_id, 
            "recipe_id" => recipe_id, 
          },  
          table_name: ENV['FAVOURITES_TABLE_NAME'] 
        })
      end
    end
  end
end
