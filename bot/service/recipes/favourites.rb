require 'aws-sdk-dynamodb'
require_relative 'user'

module Service
  module Recipe 
    module Favourite 
      extend self

      @@dynamo_resource = nil 

      def call(bot_event)
        Service::Recipe::User.upsert(bot_event.data['user']['slack_id'], bot_event.data['favourites'])
      end

      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'])
      end
    end
  end
end
