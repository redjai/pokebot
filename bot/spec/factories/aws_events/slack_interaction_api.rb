require_relative '../fixtures/aws_events/interaction_api/favourites_interaction_aws_event'
require_relative '../fixtures/aws_events/interaction_api/more_results_interaction_event'
require 'gerty/request/base'

FactoryBot.define do

  factory :aws_event_slack_interaction_favourite_recipe, class: Hash do
    initialize_with{ slack_favourites_interaction_event }
  end

end
