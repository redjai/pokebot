require 'request/base'

module TopicHelper
  extend Request::Base

end


FactoryBot.define do
  
  factory :aws_records_event, class: Hash do
    transient do
      bot_request { build(:bot_request) }
    end
    body { { "Records" => [
                            { 
                              "body" => {
                                'Message' => bot_request.to_json
                              }.to_json
                            }
                           ] } }
    initialize_with {  body  }
  end

  factory :slack_api_request_aws_event, class: Hash do
    user { 'U-SLACK-TEST-USER123' }
    channel { 'C-SLACK-TEST-CHANNEL456' }
    text { "<#{user}> slack api text"  }
    initialize_with{ slack_aws_event(attributes) }
  end

end
 
def slack_aws_event(**args)
  {
    'body' => {
       event: {
         user: args[:user],
         channel: args[:channel],
         text: args[:text]
       }
    }.to_json
  }
end
