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
    
    def favourite_new(source:, favourite_recipe_id:)
      data = {
        'favourite_recipe_id' => favourite_recipe_id.to_s
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITE_NEW , version: 1.0, data: data)      
    end

    def favourite_destroy(source:, favourite_recipe_id:)
      data = {
        'favourite_recipe_id' => favourite_recipe_id.to_s
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITE_DESTROY , version: 1.0, data: data)      
    end

    def favourites_updated(source:, favourite_recipe_ids:)
      data = {
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      Topic::Event.new(source: source, name: Topic::Users::FAVOURITES_UPDATED, version: 1.0, data: data)      
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
      Topic::Event.new(source: source, name: Topic::Recipes::SEARCH_REQUESTED, version: 1.0, data: data)      
    end

    def found(source:, recipes:, favourite_recipe_ids:, query:, offset:, per_page:, total_results:)
      data = {
        'recipes' => recipes,
        'favourite_recipe_ids' => favourite_recipe_ids,
        'query' => query,
        'page' => { 'offset' => offset, 'per_page' => per_page, 'total_results' => total_results }
      }
      Topic::Event.new(source: source, name: Topic::Recipes::FOUND, version: 1.0, data: data)      
    end

    def favourites_requested(source:, offset: 0)
      data = { offset: offset }
      Topic::Event.new(source: source, name: Topic::Recipes::FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data)      
    end
      
    def favourites_found(source:, recipes:, favourite_recipe_ids:)
      data = {
        'recipes' => recipes,
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      Topic::Event.new(source: source, name: Topic::Recipes::FOUND, version: 1.0, data: data)      
    end
  end

  module Slack
    extend self
    extend Topic::Base
    
    EVENT_API_REQUEST = 'slack-event-api-request'
    INTERACTION_API_REQUEST = 'slack-interaction-api-request'
    SHORTCUT_API_REQUEST = 'slack-shortcut-api-request'
    
    def api_event(aws_event)
      slack_data = http_data(aws_event)

      user = {
        slack_id: slack_data['event']['user'], 
         channel: slack_data['event']['channel']
      }

      record = Topic::Event.new(name: Topic::Slack::EVENT_API_REQUEST,
                                  source: 'slack-event-api',
                                 version: 1.0,
                                    data: slack_data)   
      Topic::Request.new slack_user: user, current: record
    end

    def interaction_event(aws_event)
      record = Topic::Event.new(name: Topic::Slack::INTERACTION_API_REQUEST,
                         source: 'slack-interaction-api',
                        version: 1.0,
                           data: payload_data(aws_event))
      user = {
        'slack_id' => record.record['data']['user']['id'], 
        'channel' => record.record['data']['container']['channel_id'],
        'message_ts' => record.record['data']['container']['message_ts'],
        'response_url' => record.record['data']['response_url']
      }   
      Topic::Request.new slack_user: user, current: record
    end
    
    def shortcut_event(aws_event)
      record = Topic::Event.new(  name: Topic::Slack::SHORTCUT_API_REQUEST,
                         source: 'slack-shortcut-api',
                        version: 1.0,
                           data: shortcut_data(aws_event))
      user = {
        'slack_id' => record.record['data']['user_id'].first, 
        'channel' => record.record['data']['channel_id'].first,
        'response_url' => record.record['data']['response_url'].first
      }   
      Topic::Request.new slack_user: user, current: record
    end
  end
end
