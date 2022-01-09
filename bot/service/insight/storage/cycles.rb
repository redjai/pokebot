require 'aws-sdk-dynamodb'
require 'gerty/lib/logger'

module Service
  module Insight
    module Storage
      module Cycles
        extend self
          
        @@dynamo_resource = nil 
    
        def dynamo_resource
          @@dynamo_resource ||= Aws::DynamoDB::Resource.new(options)
        end

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end
  
        def store(cycle)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['INSIGHTS_CYCLES_TABLE_NAME'],
              item: cycle.item,
              #condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end
      end
    end
  end
end
