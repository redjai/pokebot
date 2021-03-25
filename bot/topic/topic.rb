module Topic
  module Messages
    RECEIVED = 'message-received'
  end

  module Users
    FAVOURITE_NEW = 'user-favourite-new'
    FAVOURITE_DESTROY = 'user-favourite-destroy'
    FAVOURITES_UPDATED = 'user-favourites-updated'
  end

  module Recipes
    SEARCH_REQUESTED = 'recipes-search-requested'
    FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
    FOUND = 'recipes-found'
  end

  module Slack
    EVENT_API_REQUEST = 'slack-event-api-request'
    INTERACTION_API_REQUEST = 'slack-interaction-api-request'
    SHORTCUT_API_REQUEST = 'slack-shortcut-api-request'
  end
end
