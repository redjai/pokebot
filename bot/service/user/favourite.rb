require 'aws-sdk-dynamodb'
require 'topic/sns'

module Service
  module User
    module Favourite 
      extend self

      @@dynamo_resource = nil 

      def call(bot_event)
        updates = favourite(bot_event.slack_user['slack_id'], bot_event.data['favourite_recipe_id']) 
        if updates
          bot_event.current = Bot::EventBuilders.favourites_updated(source: :user, 
                                                     favourite_recipe_ids: updates['attributes']['favourites'].collect{|id| id })
          Topic::Sns.broadcast(
                                topic: :user,
                                event: bot_event
                              )
        end
      end

      private
  
      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
      end

      def favourite(user_id, recipe_id)
        begin 
          dynamo_resource.client.update_item(update_query(user_id, recipe_id))
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def update_query(user_id, recipe_id)
        {
          key: {
            "user_id" => user_id 
          },  
          update_expression: 'ADD #favourites :empty_set',
          expression_attribute_names: {
            '#favourites': 'favourites'
          },
          condition_expression: 'attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)',
          expression_attribute_values: {
            ':empty_set': Set.new([recipe_id.to_s]),
            ':recipe_id': recipe_id
          },
          table_name: ENV['FAVOURITES_TABLE_NAME'],
          return_values: 'UPDATED_NEW'
        }
      end

      def favourites(user_id)
        dynamo_resource.client.query({
          expression_attribute_values: {
            ":u1" => user_id
          },
          key_condition_expression: "user_id = :u1", 
          table_name: ENV['FAVOURITES_TABLE_NAME'],
          select: "ALL_ATTRIBUTES"
        }).items
      end

      def options
        { region: ENV['REGION'] }.tap do |opts|
          opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
          opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
        end
      end
    end
  end
end

