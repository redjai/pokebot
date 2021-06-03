require_relative '../base'
require_relative '../event'

module Request
  module Events
    module Messages
      extend self
      extend ::Request::Base

      RECEIVED = 'message-received'
      
      def received(source:, text:)
        data = {
          'text' => text
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Messages::RECEIVED, version: 1.0, data: data)      
      end
    end

    module Users
      extend self
      extend ::Request::Base
      
      FAVOURITE_NEW = 'user-favourite-new'
      FAVOURITE_DESTROY = 'user-favourite-destroy'
      FAVOURITES_UPDATED = 'user-favourites-updated'
      
      ACCOUNT_SHOW_REQUESTED = 'user-account-show-requested'
      ACCOUNT_EDIT_REQUESTED = 'user-account-edit-requested'
      ACCOUNT_READ = 'user-account-read'

      ACCOUNT_UPDATE_REQUESTED = 'user-account-update-requested' 
      ACCOUNT_UPDATED = 'user-account-updated'

      def favourite_new(source:, favourite_recipe_id:)
        data = {
          'favourite_recipe_id' => favourite_recipe_id.to_s
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::FAVOURITE_NEW , version: 1.0, data: data, intent: true)      
      end

      def favourite_destroy(source:, favourite_recipe_id:)
        data = {
          'favourite_recipe_id' => favourite_recipe_id.to_s
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::FAVOURITE_DESTROY , version: 1.0, data: data, intent: true)      
      end

      def favourites_updated(source:, favourite_recipe_ids:)
        data = {
          'favourite_recipe_ids' => favourite_recipe_ids,
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::FAVOURITES_UPDATED, version: 1.0, data: data)      
      end

      def account_show_requested(source:)
        data = {}
        ::Request::Event.new(source: source, name: ::Request::Events::Users::ACCOUNT_SHOW_REQUESTED, version: 1.0, data: data, intent: true)      
      end

      def account_read(source:, user:)
        data = {
          'user' => user
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::ACCOUNT_READ, version: 1.0, data: data)      
      end

      def account_edit_requested(source:)
        data = {}
        ::Request::Event.new(source: source, name: ::Request::Events::Users::ACCOUNT_EDIT_REQUESTED, version: 1.0, data: data, intent: true)      
      end

      def account_update_requested(source:, handle:, email:, kanbanize_username:)
        data = {
          'handle' => handle,
          'email' => email,
          'kanbanize_username' => kanbanize_username
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::ACCOUNT_UPDATE_REQUESTED, version: 1.0, data: data, intent: true)      
      end
      
      def account_updated(source:, handle:, email:, kanbanize_username:)
        data = {
          'handle' => handle,
          'email' => email,
          'kanbanize_username' => kanbanize_username
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Users::ACCOUNT_UPDATED, version: 1.0, data: data)      
      end
    end

    module Recipes
      extend self
      extend ::Request::Base
        
      SEARCH_REQUESTED = 'recipes-search-requested'
      FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
      FOUND = 'recipes-found'
      
      def search_requested(source:, query:, offset: 0, per_page: 10)
          data = {
          'query' => query,
          'page' => { 'offset' => offset, 'per_page' => per_page },
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Recipes::SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
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
        ::Request::Event.new(source: source, name: ::Request::Events::Recipes::FOUND, version: 1.0, data: data)      
      end

      def favourites_requested(source:, offset: 0)
        data = { offset: offset }
        ::Request::Event.new(source: source, name: ::Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
      end
        
    end

    module Slack
      extend self
      extend ::Request::Base
      
      EVENT_API_REQUEST = 'slack-event-api-request'
      INTERACTION_API_REQUEST = 'slack-interaction-api-request'
      SHORTCUT_API_REQUEST = 'slack-command-api-request'
      
      def api_request(aws_event)
        event = api_event(aws_event)
        ::Request::Request.new current: event, context: ::Request::SlackContext.from_slack_event(event)
      end

      def api_event(aws_event)
        ::Request::Event.new(name: ::Request::Events::Slack::EVENT_API_REQUEST,
                       source: 'slack-event-api',
                      version: 1.0,
                         data: http_data(aws_event))   
      end

      def interaction_request(aws_event)
        event = interaction_event(aws_event)
        ::Request::Request.new current: event, context: ::Request::SlackContext.from_slack_interaction(event)
      end

      def interaction_event(aws_event)
        ::Request::Event.new(name: ::Request::Events::Slack::INTERACTION_API_REQUEST,
                       source: 'slack-interaction-api',
                      version: 1.0,
                         data: payload_data(aws_event))
      end
      
      def command_request(aws_event)
        event = command_event(aws_event)
        ::Request::Request.new current: event, 
                           context: ::Request::SlackContext.from_slack_command(event)
      end

      def command_event(aws_event)
        ::Request::Event.new(  name: ::Request::Events::Slack::SHORTCUT_API_REQUEST,
                         source: 'slack-command-api',
                        version: 1.0,
                           data: command_data(aws_event))
      end
    end
  end
end
