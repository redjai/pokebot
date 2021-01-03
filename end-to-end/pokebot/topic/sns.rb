require 'aws-sdk-sns'

module Pokebot
  module Topic 
    module Sns
      extend self

      def topic
        @topic ||= resource.topic(arn)
      end
      
      private

      def region
        ENV['REGION']
      end

      def resource
        @resource ||= Aws::SNS::Resource.new(region: region)
      end

      def arn
        ENV['TOPIC_ARN']
      end

    end
  end
end
