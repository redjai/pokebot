
require_relative '../storage/movements'
require_relative '../lib/movement'

module Service
  module Insight
    module MovementsStoreService
      extend self

      def listen
        [ Gerty::Request::Events::Insights::MOVEMENTS_FOUND ]
      end

      def broadcast
         []
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        movements(bot_request).each do |movement|
          Service::Insight::Storage::Movements.store(movement)
        end
      end

      def movements(bot_request)
        bot_request.data['movements'].collect do |movement|
          Service::Insight::Movement.new(
                  team_id: movement['team_id'], 
                  board_id: movement['board_id'],
                  task_id: movement['task_id'],
              movement_id: movement['movement+_id'],
                    index: movement['index'],
                    delta: movement['delta'],
                    date: movement['date'],
                    from: movement['from'],
                    to: movement['to']
          )
        end
      end
    end
  end
end