require 'request/event'

FactoryBot.define do

  factory :activities_imported, class: ::Request::Event do

    source { :test_source }
    name { Request::Events::Kanbanize::ACTIVITIES_IMPORTED }
    version { 1.0 }
    data { 
      { 
        'board_id' => "11", 
        'client_id' => 'testlink',
        "activities" => [ build(:activity), build(:activity) ] 
      } 
    } 

    initialize_with{ ::Request::Event.new(source: source, name: name, version: version, data: data) }
  
  end

  factory :new_activities_found, class: ::Request::Event do

    source { :test_source }
    name { Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND }
    version { 1.0 }
    data { 
      { 
        'board_id' => "11", 
        'client_id' => 'testlink',
        "activities" => [ build(:activity), build(:activity) ] 
      } 
    } 

    initialize_with{ ::Request::Event.new(source: source, name: name, version: version, data: data) }
  
  end
end
