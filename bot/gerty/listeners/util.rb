require 'gerty/lib/logger'
require 'storage/kanbanize/dynamodb/team'

module Util
  class Handler
    def self.handle(event:, context:)
      Gerty::LOGGER.debug(event)
      Gerty::LOGGER.debug(context)
      
      Storage::Kanbanize::DynamoDB::Team.create(
        team_id: event['team_id'],
        board_ids: event['board_ids'].split(","),
        kanbanize_api_key: event['kanbanize_api_key'],
        subdomain: event['subdomain']
      )
  end
end
