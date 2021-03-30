require 'aws-sdk-dynamodb'
require 'topic/sns'

module Service
  module User
    module Account 
      extend self

      def call(bot_request)
        upsert(bot_request.slack_user['slack_id'], bot_request.data['handle'], bot_request.data['kanbanize_username']).tap do |updated|
          bot_request.current = Topic::Users.account_update(source: :user, handle: updated[:attributes][:handle], kanbanize_username: updated[:attributes][:kanbanize_username])
          Topic::Sns.broadcast(topic: :users, event: bot_request)
        end
      end

      @@dynamo_resource = nil 
      
      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
      end

      def destroy(user_id)
        begin 
          dynamo_resource.client.delete_item(
            {
              key: {
                "user_id" => user_id 
              },  
              table_name: ENV['FAVOURITES_TABLE_NAME']
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def upsert(user_id, handle, kanbanize_username)
        begin 
          dynamo_resource.client.update_item(
            {
              key: {
                "user_id" => user_id 
              },  
              update_expression: 'SET #handle = :handle, #kanbanize_username = :kanbanize_username',
              expression_attribute_names: {
                '#handle': 'handle',
                '#kanbanize_username': 'kanbanize_username'
              },
              expression_attribute_values: {
                ':handle': handle,
                ':kanbanize_username': kanbanize_username
              },
              table_name: ENV['FAVOURITES_TABLE_NAME'],
              return_values: 'UPDATED_NEW'
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def read(user_id)
        dynamo_resource.client.query({
          expression_attribute_values: {
            ":u1" => user_id
          },
          key_condition_expression: "user_id = :u1", 
          table_name: ENV['FAVOURITES_TABLE_NAME'],
          select: "ALL_ATTRIBUTES"
        }).items.first
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

