require_relative '../base'
require_relative '../event'

module Request
  module Events
    module Kanbanize 
      extend self
      extend ::Request::Base

      ACTIVITIES_IMPORTED = 'activities-imported'
      NEW_ACTIVITIES_FOUND = 'new-activities-found'
      
      def activities_imported(source:, board_id:, activities:)
        data = {
          'board_id' => board_id,
          'activities' => activities
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Kanbanize::ACTIVITIES_IMPORTED, version: 1.0, data: data)      
      end
      
      def new_activities_found(source:, board_id:, activities:)
        data = {
          'board_id' => board_id,
          'activities' => activities
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND, version: 1.0, data: data)      
      end
    end
  end
end
