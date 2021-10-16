require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Users
        extend self
        extend Gerty::Request::Base
        
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
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::FAVOURITE_NEW , version: 1.0, data: data, intent: true)      
        end

        def favourite_destroy(source:, favourite_recipe_id:)
          data = {
            'favourite_recipe_id' => favourite_recipe_id.to_s
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::FAVOURITE_DESTROY , version: 1.0, data: data, intent: true)      
        end

        def favourites_updated(source:, favourite_recipe_ids:)
          data = {
            'favourite_recipe_ids' => favourite_recipe_ids,
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::FAVOURITES_UPDATED, version: 1.0, data: data)      
        end

        def account_show_requested(source:)
          data = {}
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::ACCOUNT_SHOW_REQUESTED, version: 1.0, data: data, intent: true)      
        end

        def account_read(source:, user:)
          data = {
            'user' => user
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::ACCOUNT_READ, version: 1.0, data: data)      
        end

        def account_edit_requested(source:)
          data = {}
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::ACCOUNT_EDIT_REQUESTED, version: 1.0, data: data, intent: true)      
        end

        def account_update_requested(source:, handle:, email:, kanbanize_username:)
          data = {
            'handle' => handle,
            'email' => email,
            'kanbanize_username' => kanbanize_username
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::ACCOUNT_UPDATE_REQUESTED, version: 1.0, data: data, intent: true)      
        end
        
        def account_updated(source:, handle:, email:, kanbanize_username:)
          data = {
            'handle' => handle,
            'email' => email,
            'kanbanize_username' => kanbanize_username
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Users::ACCOUNT_UPDATED, version: 1.0, data: data)      
        end
      end

    end
  end
end