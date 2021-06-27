require 'request/event'
require 'request/events/cron'


FactoryBot.define do

  factory :kanbanize_import_transition_activities, class: ::Request::Event do
  
    initialize_with{ ::Request::Events::Cron.cron_event({ "client_id" => 'test-client-1', "action" => ::Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES, "event_type" => "Transitions" }) }

  end

end
