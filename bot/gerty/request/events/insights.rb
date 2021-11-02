require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Insights
        extend self
        extend Gerty::Request::Base

        
        ACTIVITIES_REQUESTED = 'activities_requested'
      
        def activities_requested(source:, target:, date_range:)
          data = {
            'target' => target,
            'date_range' => date_range
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Insights::ACTIVITIES_REQUESTED, version: 1.0, data: data)      
        end
      end
    end
  end
end