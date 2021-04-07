require_relative 'base'

module Topic
  module Messages
    extend self
    extend Topic::Base

    RECEIVED = 'message-received'
    
    def received(source:, text:)
      data = {
        'text' => text
      }
      Topic::Event.new(source: source, name: Topic::Messages::RECEIVED, version: 1.0, data: data)      
    end
  end

  module Users
    extend self
    extend Topic::Base
    
    FAVOURITE_NEW = 'user-favourite-new'
    FAVOURITE_DESTROY = 'user-favourite-destroy'
    FAVOURITES_UPDATED = 'user-favourites-updated'
    
    ACCOUNT_SHOW_REQUESTED = 'user-account-requested'
    ACCOUNT_EDIT_REQUESTED = 'user-account-edit'
    ACCOUNT_READ = 'user-account-read'

    ACOUNT_UPDATE_REQUESTED = 'user-account-update-requested' 
    ACCOUNT_UPDATED = 'user-account-update'

    def favourite_new(source:, favourite_recipe_id:)
      data = {
        'favourite_recipe_id' => favourite_recipe_id.to_s
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITE_NEW , version: 1.0, data: data, intent: true)      
    end

    def favourite_destroy(source:, favourite_recipe_id:)
      data = {
        'favourite_recipe_id' => favourite_recipe_id.to_s
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITE_DESTROY , version: 1.0, data: data, intent: true)      
    end

    def favourites_updated(source:, favourite_recipe_ids:)
      data = {
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITES_UPDATED, version: 1.0, data: data)      
    end

    def account_requested(source:)
      data = {}
      Topic::Event.new(source: source, name: Topic::Users::ACCOUNT_SHOW_REQUESTED, version: 1.0, data: data, intent: true)      
    end

    def account_read(source:, user:)
      data = {
        'user' => user
      }
      Topic::Event.new(source: source, name: Topic::Users::ACCOUNT_READ, version: 1.0, data: data)      
    end

    def account_edit(source:)
      data = {}
      Topic::Event.new(source: source, name: Topic::Users::ACCOUNT_EDIT_REQUESTED, version: 1.0, data: data, intent: true)      
    end
    
    def account_updated(source:, user:)
      data = {
        user: user
      }
      Topic::Event.new(source: source, name: Topic::Users::ACCOUNT_UPDATED, version: 1.0, data: data)      
    end
  end

  module Recipes
    extend self
    extend Topic::Base
      
    SEARCH_REQUESTED = 'recipes-search-requested'
    FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
    FOUND = 'recipes-found'
    
    def search_requested(source:, query:, offset: 0, per_page: 10)
        data = {
        'query' => query,
        'page' => { 'offset' => offset, 'per_page' => per_page },
      }
      Topic::Event.new(source: source, name: Topic::Recipes::SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
    end

    def found(source:, recipes:, favourite_recipe_ids:, query: nil, offset: nil, per_page: nil, total_results: nil)
      data = {
        'recipes' => recipes,
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      if query
        data['query'] = query
        data['page'] = { 'offset' => offset, 'per_page' => per_page, 'total_results' => total_results }
      end
      Topic::Event.new(source: source, name: Topic::Recipes::FOUND, version: 1.0, data: data)      
    end

    def favourites_requested(source:, offset: 0)
      data = { offset: offset }
      Topic::Event.new(source: source, name: Topic::Recipes::FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
    end
      
  end

  module Slack
    extend self
    extend Topic::Base
    
    EVENT_API_REQUEST = 'slack-event-api-request'
    INTERACTION_API_REQUEST = 'slack-interaction-api-request'
    SHORTCUT_API_REQUEST = 'slack-command-api-request'
    
    def api_request(aws_event)
      event = api_event(aws_event)
      Topic::Request.new current: event, context: Topic::SlackContext.from_slack_event(event)
    end

    def api_event(aws_event)
      Topic::Event.new(name: Topic::Slack::EVENT_API_REQUEST,
                     source: 'slack-event-api',
                    version: 1.0,
                       data: http_data(aws_event))   
    end

    def interaction_request(aws_event)
      event = interaction_event(aws_event)
      Topic::Request.new current: event, context: Topic::SlackContext.from_slack_interaction(event)
    end

    def interaction_event(aws_event)
      Topic::Event.new(name: Topic::Slack::INTERACTION_API_REQUEST,
                     source: 'slack-interaction-api',
                    version: 1.0,
                       data: payload_data(aws_event))
    end
    
    def command_request(aws_event)
      event = command_event(aws_event)
      Topic::Request.new current: event, 
                         context: Topic::SlackContext.from_slack_command(event)
    end

    def command_event(aws_event)
      Topic::Event.new(  name: Topic::Slack::SHORTCUT_API_REQUEST,
                       source: 'slack-command-api',
                      version: 1.0,
                         data: command_data(aws_event))
    end
  end
end
