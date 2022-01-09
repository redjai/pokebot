require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Insights
        extend self
        extend Gerty::Request::Base

        BUILD_ACTIVE_CYCLES = 'build_active_cycles'
        MOVEMENTS_FOUND = 'movements_found'
        DEVELOPER_INSIGHTS_REQUESTED = 'developer_insights_requested'
        DEVELOPER_INSIGHTS_FOUND = 'developer_insights_found'

        def movements_found(source:, movements:)
          data = {
            'movements' => movements
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Insights::MOVEMENTS_FOUND, version: 1.0, data: data)      
        end

        def developer_insights_requested(source:, target:, date_range:)
          data = {
            'target' => target,
            'date_range' => date_range
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Insights::DEVELOPER_INSIGHTS_REQUESTED, version: 1.0, data: data)      
        end  

        def developer_insights_found(source:, tasks:, activities:)
          data = {
            'tasks' => tasks,
            'activities' => activities
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Insights::DEVELOPER_INSIGHTS_FOUND, version: 1.0, data: data)      
        end
      end
    end
  end
end