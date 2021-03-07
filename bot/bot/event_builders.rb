require_relative 'event'

module Bot
  module EventBuilders
    extend self

    def message_received(source:, text:)
      data = {
        'text' => text
      }
      Bot::EventRecord.new(source: source, name: MESSAGE_RECEIVED, version: 1.0, data: data)      
    end

    def recipe_search_requested(source:, query:, offset: 0)
      data = {
        'query' => query,
        'offset' => offset 
      }
      Bot::EventRecord.new(source: source, name: RECIPE_SEARCH_REQUESTED, version: 1.0, data: data)      
    end

    def recipes_found(source:, complex_search:, information_bulk:, favourite_recipe_ids:, query:)
      data = {
        'complex_search' => complex_search,
        'information_bulk' => information_bulk,
        'favourite_recipe_ids' => favourite_recipe_ids,
        'query' => query 
      }
      Bot::EventRecord.new(source: source, name: RECIPES_FOUND, version: 1.0, data: data)      
    end

    def favourite_search_requested(source:, offset: 0)
      data = { offset: offset }
      Bot::EventRecord.new(source: source, name: FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data)      
    end
    
    def favourites_search(source:, information_bulk:, favourite_recipe_ids:)
      data = {
        'information_bulk' => information_bulk,
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      Bot::EventRecord.new(source: source, name: RECIPES_FOUND, version: 1.0, data: data)      
    end
    
    def favourite_new(source:, favourite_recipe_id:)
      data = {
        'favourite_recipe_id' => favourite_recipe_id
      }
      Bot::EventRecord.new(source: source, name: USER_FAVOURITE_NEW , version: 1.0, data: data)      
    end

    def favourites_updated(source:, favourite_recipe_ids:)
      data = {
        'favourite_recipe_ids' => favourite_recipe_ids,
      }
      Bot::EventRecord.new(source: source, name: USER_FAVOURITES_UPDATED, version: 1.0, data: data)      
    end

    def more_search_results_requested(source:, query:, ts:, offset: 0)
      data = { 
        query: query,
        offset: offset,
        ts: ts,
      }
      Bot::EventRecord.new(source: source, name: RECIPE_SEARCH_NEXT_PAGE, version: 1.0, data: data)      
    end 

    def slack_api_event(aws_event)
      slack_data = http_data(aws_event)

      user = {
        slack_id: slack_data['event']['user'], 
         channel: slack_data['event']['channel']
      }

      record = Bot::EventRecord.new(name: 'slack-event-api-request',
                                  source: 'slack-event-api',
                                 version: 1.0,
                                    data: slack_data)   
      Bot::Event.new slack_user: user, current: record
    end

    def slack_interaction_event(aws_event)
      record = Bot::EventRecord.new(  name: 'slack-interaction-api-request',
                         source: 'slack-interaction-api',
                        version: 1.0,
                           data: payload_data(aws_event))
      user = {'slack_id' => record.record['data']['user']['id'], 'channel' => record.record['data']['container']['channel_id']}   
      Bot::Event.new slack_user: user, current: record
    end

    private

    def http_data(aws_event)
      data(aws_event)
    end

    def payload_data(aws_event)
      require 'uri'
      JSON.parse(CGI.unescape(body(aws_event).gsub(/^payload=/,"")))
    end

    def data(aws_event)
      JSON.parse(body(aws_event))
    end

    def body(aws_event)
      if aws_event["isBase64Encoded"]
        require 'base64'
        Base64.decode64(aws_event['body'])
      else
        aws_event['body']
      end
    end
  end
end
