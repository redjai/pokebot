require_relative '../../blocks/builder'

module Service
  module Responder
    module Slack
      module Views
        module Recipes
          class Index
          include Service::Responder::Slack::BlockBuilder

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
                section['accessory'] = image_accessory(image_url: recipe['image'], alt_text: 'recipe image') if recipe['image'] =~ URI::regexp
              end
            end

            def recipe_section(recipe)
              text_section(
%{*#{recipe['title']}* #{favourite_icon?(recipe['id'])}
#{recipe['extendedIngredients'].collect{|ing| ing['name']}.join(", ")}
_ready in #{recipe["readyInMinutes"]} minutes_}
              )
            end

            def recipe_image(recipe)
              image_accessory(image_url: recipe['image'], alt_text: recipe['title'])
            end

            def view_recipe_button_element(url)
              button_element(text: "View", value: "click_me_123", options: {url: url})
            end

            def favourite_unfavourite_button_element(recipe_id)
              favourite?(recipe_id) ? unfavourite_button_element(recipe_id) : favourite_button_element(recipe_id)
            end

            def favourite_button_element(recipe_id)
              button_element(text: "Favourite", value: { interaction: 'favourite', data: recipe_id }.to_json)
            end

            def unfavourite_button_element(recipe_id)
              button_element(text: "Unfavourite", value: { interaction: 'unfavourite', data: recipe_id }.to_json)
            end

            def button_block(recipe)
              actions(
                view_recipe_button_element(recipe['sourceUrl']),
                favourite_unfavourite_button_element(recipe['id'])
              ) 
            end


            def nav_block(query:, offset:, per_page:, total_results:)
              elements = []

              if less?(offset, per_page)
                elements << nav_block_button("back", { 'query' => query, 'per_page' => per_page, 'offset' => offset - per_page }) 
              end

              if more?(offset, per_page, total_results)
                elements << nav_block_button("more", { 'query' => query,  'per_page' => per_page, 'offset' => offset + per_page }) 
              end
              
              if elements.size > 0
                actions(elements)
              end
            end

            def less?(offset, per_page)
              offset - per_page > 1
            end

            def more?(offset, per_page, total_results)
              offset + per_page < total_results
            end

            def nav_block_button(text, data)
              button_element(text: text, value: { interaction: 'next-recipes', data: data }.to_json)
            end
            
            def favourite?(recipe_id)
              @bot_request.data['favourite_recipe_ids'].include?(recipe_id.to_s)
            end
            
            def favourite_icon?(recipe_id)
              favourite?(recipe_id) ? ':star:' : '' 
            end

          end
        end
      end
    end
  end
end
