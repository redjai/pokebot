require 'gerty/request/event'
require 'gerty/request/events/slack'
require_relative '../../fixtures/aws_events/interaction_api/user_update_requested_view_submission'
require_relative '../../fixtures/aws_events/interaction_api/favourites_interaction_aws_event'

FactoryBot.define do
  factory :slack_interaction_user_account_update_request, class: Gerty::Request::Request do
    initialize_with{ Gerty::Request::Events::Slack.interaction_request(user_update_requested_view_submission) }
  end

  factory :slack_interaction_favourite_recipe_request, class: Gerty::Request::Request do
    initialize_with{ Gerty::Request::Events::Slack.interaction_request(slack_favourites_interaction_event) }
  end

  factory :slack_interaction_more_results_request, class: Gerty::Request::Request do
    initialize_with{ Gerty::Request::Events::Slack.interaction_request(slack_more_results_interaction_event) }
  end

  factory :slack_interaction_favourite_recipe_event, class: ::Gerty::Request::Event do
    initialize_with{ Gerty::Request::Events::Slack.interaction_event(slack_favourites_interaction_event) }
  end

  factory :slack_interaction_user_account_update_event, class: ::Gerty::Request::Event do
    initialize_with{ Gerty::Request::Events::Slack.interaction_event(user_update_requested_view_submission) } 
  end
end
