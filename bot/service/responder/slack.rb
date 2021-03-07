require 'slack/response'

module Service
  module Responder
    module Slack
      extend self
      
      def call(bot_request)
        case bot_request.name
        when Bot::RECIPES_FOUND
          respond_with_recipes(bot_request)
        when Bot::MESSAGE_RECEIVED
          respond_searching(bot_request)
        else
          raise "unexpected event name #{bot_request.name}"
        end
      end

      def respond_searching(bot_request)
        ::Slack::Response.respond(
          channel: bot_request.slack_user['channel'], 
          text: "searching for #{bot_request.data['text']} recipes... :male-cook: :knife_fork_plate: :female-cook:",
        )
      end

      def respond_with_recipes(bot_request)
        ::Slack::Response.respond(
          channel: bot_request.slack_user['channel'], 
          text: 'recipes:',
          blocks:  RecipeBlocks.new(bot_request).recipe_blocks
        )
      end

      class RecipeBlocks

        def initialize(bot_request)
          @bot_request = bot_request
        end

        def recipe_blocks
          
          puts @bot_request.data['complex_search'].inspect
          @bot_request.data['information_bulk'].collect do |recipe|
            [recipe_block(recipe), button_block(recipe)]
          end
          .push(divider_block)
          .push(nav_block(@bot_request.data['complex_search']['totalResults'],
                          @bot_request.data['complex_search']['number'], 
                          @bot_request.data['query']))
            .flatten.compact
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

        def nav_block(total_results, number, query)
          elements = []

          if less?(query['offset'], number)
            elements << nav_block_button("back", query.merge({ 'offset' => query['offset'] - number })) 
          end

          if more?(query['offset'], number, total_results)
            elements << nav_block_button("more", query.merge({ 'offset' => query['offset'] + number })) 
          end

          if elements.size > 0
            {
              "type": "actions",
              "elements": elements
            }
          end
        end

        def less?(offset, number)
          offset - number > 1
        end

        def more?(offset, number, total_results)
          offset + number < total_results
        end

        def nav_block_button(text, data)
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": text,
              "emoji": true
            },
            "value": { interaction: 'next-recipes', data: data }.to_json,
          }
        end
        
        def favourite?(recipe_id)
          if @bot_request.data['favourite_recipe_ids'].include?(recipe_id)
            ':star:'  
          end
        end

      end
    end
  end
end
