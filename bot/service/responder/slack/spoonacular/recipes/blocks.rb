module Service
  module Responder
    module Slack
      module Recipes
        module Spoonacular
          class Blocks

            def initialize(bot_request)
              @bot_request = bot_request
            end

            def recipe_blocks
              blocks = []
              @bot_request.data.tap do |data|
                data['recipes'].collect do |recipe|
                  blocks << [recipe_block(recipe), button_block(recipe)]
                end
                blocks.push(divider_block)
                blocks.push(nav_block(
                                  query: data['query'], 
                                  offset: data['page']['offset'],
                                  per_page: data['page']['per_page'],
                                  total_results: data['page']['total_results']
                                )) if data['page']
              end
              blocks.flatten.compact
            end

            def recipe_block(recipe)
              recipe_section(recipe).tap do |section|
                section['accessory'] = image_accessory(recipe) if recipe['image'] =~ URI::regexp
              end
            end

            def recipe_section(recipe)
              {
                type: "section",
                text: {
                  type: "mrkdwn",
                  text: "*#{recipe['title']}* #{favourite?(recipe['id'])}\n#{recipe['extendedIngredients'].collect{|ing| ing['name']}.join(", ")}\n_ready in #{recipe["readyInMinutes"]} minutes_"
                }
              }
            end

            def image_accessory(recipe)
              {
                type: "image",
                image_url: recipe['image'],
                alt_text: recipe['title']
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

            def nav_block(query:, offset:, per_page:, total_results:)
              elements = []

              if less?(offset, per_page)
                elements << nav_block_button("back", {'query' => query, 'per_page' => per_page, 'offset' => offset - per_page }) 
              end

              if more?(offset, per_page, total_results)
                elements << nav_block_button("more", { 'query' => query,  'per_page' => per_page, 'offset' => offset + per_page }) 
              end

              if elements.size > 0
                {
                  "type": "actions",
                  "elements": elements
                }
              end
            end

            def less?(offset, per_page)
              offset - per_page > 1
            end

            def more?(offset, per_page, total_results)
              offset + per_page < total_results
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
              if @bot_request.data['favourite_recipe_ids'].include?(recipe_id.to_s)
                ':star:'  
              end
            end

          end
        end
      end
    end
  end
end
