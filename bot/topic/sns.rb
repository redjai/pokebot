require 'handlers/processors/sqs'
require 'aws-sdk-sns'
require 'json'

module Topic 
  module Sns
    extend self
    
    @@topics = {}

    def broadcast(topic:, request:)
      Bot::LOGGER.debug("out:")
      Bot::LOGGER.debug(topic)
      request.next.each_with_index do |next_request, i|
        Bot::LOGGER.debug("next event #{i}")
        Bot::LOGGER.debug(next_request.to_json)
      end
      [topic].flatten.each do |t|
        request.next.each do |next_request|
          topic(topic: t).publish( message: next_request.to_json )
        end
      end
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
