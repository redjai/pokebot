require_relative '../storage/named_cycles'
require_relative '../storage/cycles'
require_relative '../storage/movements'
require_relative '../lib/movement'
require_relative '../lib/cycles'

require 'storage/dynamodb/team'

module Service
  module Insight
    module NamedCyclesCronService
      extend self
      extend ::Storage::DynamoDB::Team

      REPEAT = 7
      CYCLE_LENGTH = 28

      def listen
        [ Gerty::Request::Events::Insights::BUILD_ACTIVE_CYCLES ]
      end

      def broadcast
         []
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        if bot_request.data['name'] && bot_request.data['team_id'] && bot_request.data['board_id']
          named_cycle( 
              team_id: bot_request.data['team_id'], 
             board_id: bot_request.data['board_id'], 
                 name: bot_request.data['name'],
                after: DateTime.parse(bot_request.data['after']),
               before: DateTime.parse(bot_request.data['before'])  
          )
        else 
          active_cycles
        end
      end

      def named_cycle(team_id:, board_id:, name:, after:, before:)
        named_cycle = Service::Insight::Storage::NamedCycles.named_cycle(team_id: team_id, board_id: board_id, name: name)
        process_named_cycle(
          team_id: team_id,
          board_id: board_id,
          named_cycle: named_cycle,
          after: after,
          before: before
        )
      end

      def active_cycles
        get_teams.each do |team|
          team.board_ids.each do |board_id|
            Service::Insight::Storage::NamedCycles.active_cycles(team_id: team.team_id, board_id: board_id).each do |named_cycle|
              process_named_cycle(
                team_id: team.team_id,
                board_id: board_id,
                named_cycle: named_cycle,
                after: default_after,
                before: default_before
              )
            end
          end
        end
      end

      def process_named_cycle(team_id:, board_id:, named_cycle:, after:, before:)
        cycles = Cycles.new(
              team_id: team_id,
             board_id: board_id,
          named_cycle: named_cycle, 
                after: after, 
               before: before
        )
        Service::Insight::Storage::Cycles.store(cycles.cycle)
      end

      def default_before
        Date.today
      end

      def default_after
        Date.today - CYCLE_LENGTH
      end
  
    end
  end
end
