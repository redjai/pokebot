module Gerty
  module Request 
    class Request 
      
      attr_reader :current, :context
      
      def initialize(current:, context: ::Gerty::Request::SlackContext.new, trail: [], user: nil)
        @context = context
        @current = current.to_h
        @trail = trail
        @user = user
      end

      def initialize_copy(other)
        @context = other.context
        @current = other.current
        @trail = other.trail.dup
        @user = other.user
      end

      def data
        current['data']
      end

      def name
        current['name']
      end

      def user(auto_load: true)
        @user ||= begin
          return nil unless auto_load
          require 'storage/kanbanize/dynamodb/user'
          Storage::Kanbanize::DynamoDB::User.read( team_id: context.team_id, 
                                                  slack_id: context.slack_id )
        end
      end

      def team
        @team ||= begin
          return nil unless auto_load
          require 'storage/kanbanize/dynamodb/team'
          Storage::Kanbanize::DynamoDB::Team.fetch_team(context.team_id)
        end
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
              context: @context.to_h,
              user: user(auto_load: false)
            }
          end
        end
      end

      def to_json(options = {})
        { 
          current: @current, 
          trail: @trail, 
          context: @context.to_h,
          user: user(auto_load: false)
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
