require 'pokebot/lambda/event'
require 'aws-sdk-sns'
require 'json'

module Pokebot
  module Topic 
    module Sns
      extend self

      @@topics = {}

      def broadcast(topic:, source:, name:, version:, event:, data: {})
        record = Pokebot::Lambda::Event::BotEventRecord.new(  name: name,
                                    source: source,
                                   version: version,
                                      data: data )
        event.current = record
        puts "out:"
        puts event.to_json
        topic(topic: topic).publish( message: event.to_json )
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
