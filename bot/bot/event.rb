require 'json'

module Bot
  class EventRecord
    
    attr_reader :record

    def initialize(source:, name:, version:, data: [])
      @record = { 'name' => name, 
                  'metadata' => 
                     { 'source' => source, 
                       'version' => version, 
                       'ts' => Time.now.to_f },
                  'data' => data }
    end

    def to_h
      @record.to_h
    end

  end

  class Event

    MESSAGE_RECEIVED = 'slack-message-received'
    RECIPE_SEARCH_REQUESTED = 'recipes-search-requested'
    RECIPE_SEARCH_NEXT_PAGE = 'recipes-search-next-page'
    FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
    RECIPES_FOUND = 'recipes-found'
    FAVOURITE_NEW = 'favourite-new'
    USER_FAVOURITES_UPDATED = 'user-favourites-updated'
    SLACK_EVENT_API_REQUEST = 'slack-event-api-request'
    
    attr_reader :current

    def initialize(current:, trail: [])
      @current = current.to_h
      @trail = trail
    end

    def data
      current['data']
    end

    def name
      current['name']
    end

    def current=(record)
      trail.unshift(@current.to_h)
      @current = record.to_h
    end

    def trail
      @trail ||= []
    end

    def to_json
      { current: @current, trail: @trail }.to_json 
    end
  end
end

