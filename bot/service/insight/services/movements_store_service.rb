
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
        [ :insights ]
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        bot_request.data['movements'].each do |movement|
          puts movement.inspect
          #Service::Insight::Storage::Movements.store(movement)
        end
      end
    end
  end
end