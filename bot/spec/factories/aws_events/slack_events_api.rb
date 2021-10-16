require_relative '../fixtures/aws_events/events_api/recipe_search_api_event'
require_relative '../fixtures/aws_events/events_api/challenge'
require 'gerty/request/base'

module TopicHelper
  extend Request::Base

end


FactoryBot.define do
  
  factory :slack_recipe_search_aws_event, class: Hash do
    initialize_with{ recipe_search_api_event }
  end

  factory :slack_challenge_aws_event, class: Hash do
    challenge { 'slack-challenge-1234' }
    initialize_with{ slack_challenge(attributes) }
  end
end
