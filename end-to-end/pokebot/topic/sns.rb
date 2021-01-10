require 'aws-sdk-sns'
require 'json'

module Pokebot
  module Topic 
    module Sns
      extend self

      @@topics = {}

      def broadcast(topic:, event:, state:)
        topic(topic: topic).publish(message: {event: event, state: state}.to_json)
      end

      private

      def topic(topic:) 
        @@topics[topic] ||= resource.topic(arn(topic))
      end

      def region
        ENV['REGION']
      end

      def resource
        @resource ||= Aws::SNS::Resource.new(region: region)
      end

      def arn(topic)
        ENV["#{topic.to_s.upcase}_TOPIC_ARN"]
      end

    end
  end
end
