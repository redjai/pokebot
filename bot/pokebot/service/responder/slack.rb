require 'pokebot/slack/response'

module Pokebot
  module Service
    module Responder
      module Slack
        extend self
        
        def call(event)
          if event.spoonacular_recipe_response?
            respond_with_recipes(event)
          else
            respond_searching(event)
          end
        end

        def respond_searching(event)
          Pokebot::Slack::Response.respond(
            channel: event.channel, 
            text: "searching for #{event.slack_text} recipes... :male-cook: :knife_fork_plate: :female-cook:",
          )
        end

        def respond_with_recipes(event)
          Pokebot::Slack::Response.respond(
            channel: event.channel, 
            text: 'recipes:',
            blocks:  recipe_blocks(event.spoonacular_recipes)
          )
        end

        def recipe_blocks(information_bulk)
          information_bulk.collect do |recipe|
            [recipe_block(recipe), button_block(recipe)]
          end.flatten
        end

        def recipe_block(recipe)
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*#{recipe['title']}*\n#{recipe['extendedIngredients'].collect{|ing| ing['name']}.join(", ")}\n_ready in #{recipe["readyInMinutes"]} minutes_"
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
                "value": "Favourite-#{recipe['id']}",
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
      end
    end
  end
end
