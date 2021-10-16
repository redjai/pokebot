module Gerty
  module Request 
    class Request 
      
      attr_reader :current, :context

      def initialize(current:, context: ::Request::SlackContext.new, trail: [])
        @context = context
        @current = current.to_h
        @trail = trail
      end

      def initialize_copy(other)
        @context = other.context
        @current = other.current
        @trail = other.trail.dup
      end

      def data(index=0)
        current['data']
      end

      def name
        current['name']
      end

      # intent was when we couldn't understand why a user has interacted
      # lets replace this by using SlackContext private-metadata in interactions 
      # def intent
      #   all.find do |event|
      #     event['intent']
      #   end
      # end

      # def intent?
      #   !intent.nil?
      # end

      def events?
        events.any?
      end

      def events
        @events ||= EventArray.new
      end

      def trail
        @trail ||= []
      end
      
      def next
        @next ||= begin
          next_trail = [@current] + @trail
          events.collect do |event|
            { 
              current: event, 
              trail: next_trail, 
              context: @context.to_h 
            }
          end
        end
      end

      def to_json(options = {})
        { 
          current: @current, 
          trail: @trail, 
          context: @context.to_h 
        }.to_json
      end

      private

      def _events
        @events ||= []
      end

      def all
        [@current] + trail 
      end

    end

    class EventArray < Array

      def clean!
        @dirty = false
      end

      def dirty?
        @dirty == true
      end

      def <<(event)
        push event.to_h if event
        @dirty = true
      end
    end
  end
end
