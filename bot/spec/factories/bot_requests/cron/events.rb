require 'gerty/request/event'
require 'gerty/request/events/cron'


FactoryBot.define do

  factory :kanbanize_import_transition_activities, class: ::Gerty::Request::Event do
  
    initialize_with{ Gerty::Request::Events::Cron.cron_event({ "client_id" => 'test-client-1', "action" => Gerty::Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES, "event_type" => "Transitions" }) }

  end

end
