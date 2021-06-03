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
  end
end
