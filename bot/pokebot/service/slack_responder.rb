require 'pokebot/slack/response'

module Pokebot
  module Service
    module SlackResponder
      extend self
      
      def call(pokebot_event)
        Pokebot::Slack::Response.respond(
          channel: pokebot_event['state']['slack']['event']['channel'], 
          text: 'recipes:',
          blocks:  recipe_blocks(pokebot_event['state']['bot']['spoonacular']['search'])
        )
      end

      def recipe_blocks(results)
        results['results'].collect do |result|
          block(result)
        end
      end

      def block(result)
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "# #{result['title']}"
          },
          accessory: {
            type: "image",
            image_url: result['image'],
            alt_text: result['title']
          }
		    }
      end
    end
  end
end
