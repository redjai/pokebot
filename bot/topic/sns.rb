require 'handlers/lambda/event'
require 'aws-sdk-sns'
require 'json'

module Topic 
  module Sns
    extend self

    @@topics = {}

    def broadcast(topic:, request:)
      Bot::LOGGER.debug("out:")
      Bot::LOGGER.debug(topic)
      Bot::LOGGER.debug(request.to_json)
      topic(topic: topic).publish( message: request.to_json )
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
