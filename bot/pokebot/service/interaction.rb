require 'pokebot/topic/sns'

module Pokebot
  module Service
    module Interaction
      extend self

      def call(interaction_event)
        interaction_event['state']['slack']['interaction']['actions'].each do |action|
          if action['value'] =~ /^Favourite-(.+)/
            interaction_event['state']['interaction'] = { 'favourite' => $1 } 
            Pokebot::Topic::Sns.broadcast(topic: :interactions, event: Pokebot::Lambda::Event::FAVOURITE_NEW, state: interaction_event['state'])
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
