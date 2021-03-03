require_relative 'slack_events/favourites_interaction_aws_event'
require_relative 'slack_events/more_results_interaction_event'

FactoryBot.define do

  factory :slack_api_request_aws_event, class: Hash do
    user { 'U-SLACK-TEST-USER123' }
    channel { 'C-SLACK-TEST-CHANNEL456' }
    text { "<#{user}> slack api text"  }
    initialize_with{ slack_aws_event(attributes) }
  end
  
  factory :slack_favourites_interaction_event, class: Hash do
    initialize_with{ slack_favourites_interaction_event }
  end

  factory :slack_more_results_interaction_event, class: Hash do
    initialize_with{ slack_more_results_interaction_event }
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
