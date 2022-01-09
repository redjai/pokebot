
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
          Service::Insight::Movement.from_event(movement)
        end
      end
    end
  end
end