require 'aws-sdk-sns'

# *********************
# ****** AWS SNS ******
# *********************

def region
  ENV['REGION']
end

def resource
  @resource ||= Aws::SNS::Resource.new(region: region)
end

def arn
  ENV['TOPIC_ARN']
end

def topic
  @topic ||= resource.topic(arn)
end
