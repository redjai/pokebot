require 'slack/response'

module Service
  module Responder
    module Slack
      extend self
      
      def call(bot_event)
        case bot_event.name
        when Bot::Event::RECIPES_FOUND
          respond_with_recipes(bot_event)
        when Bot::Event::MESSAGE_RECEIVED
          respond_searching(bot_event)
        else
          raise "unexpected event name #{bot_event.name}"
        end
      end

      def respond_searching(bot_event)
        ::Slack::Response.respond(
          channel: bot_event.data['user']['channel'], 
          text: "searching for #{bot_event.data['text']} recipes... :male-cook: :knife_fork_plate: :female-cook:",
        )
      end

      def respond_with_recipes(bot_event)
        ::Slack::Response.respond(
          channel: bot_event.data['user']['channel'], 
          text: 'recipes:',
          blocks:  RecipeBlocks.new(bot_event).recipe_blocks
        )
      end

      class RecipeBlocks

        def initialize(bot_event)
          @bot_event = bot_event
        end

        def recipe_blocks
          @bot_event.data['recipes']['information_bulk'].collect do |recipe|
            [recipe_block(recipe), button_block(recipe)]
          end.push(divider_block).push(nav_block(@bot_event.data['query'])).flatten
        end

        def recipe_block(recipe)
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*#{recipe['title']}* #{favourite?(recipe['id'])}\n#{recipe['extendedIngredients'].collect{|ing| ing['name']}.join(", ")}\n_ready in #{recipe["readyInMinutes"]} minutes_"
            },
            accessory: {
              type: "image",
              image_url: recipe['image'],
              alt_text: recipe['title']
            }
          }
        end

        def button_block(recipe)
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "View",
                  "emoji": true
                },
                "value": "click_me_123",
                "url": recipe['sourceUrl'] 
              },
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "Favourite",
                  "emoji": true
                },
                "value": { interaction: 'favourite', data: recipe['id'] }.to_json,
              },
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "Email me Ingredients",
                  "emoji": true
                },
                "value": "email-#{recipe['id']}",
              }
            ]
          }
        end

        def divider_block
          {
            "type": "divider"
          }
        end

        def nav_block(query)
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "More",
                  "emoji": true
                },
                "value": { interaction: 'next-recipes', data: query }.to_json,
              }
            ]
          }
        end
        
        def favourite?(recipe_id)
          if @bot_event.data['recipes']['favourite_recipe_ids'].include?(recipe_id)
            ':star:'  
          end
        end

      end
    end
  end
end
