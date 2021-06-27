require 'request/events/kanbanize'
require 'topic/sns'
require 'date'
require 'aws-sdk-s3'

module Service
  module Kanbanize
    module BoardActivitiesImported # change this name 
      extend self

      def call(bot_request)
        activities = Activities.new(bot_request.data['board_id'], bot_request.data['activities'])
        activities.store_new_activities!
        
        bot_request.current = activities.new_activities_event

        Topic::Sns.broadcast(
          topic: :kanbanize,
          request: bot_request
        ) 
      end

    end

    class Activities

      def client 
        @client ||= Aws::S3::Resource.new(region: ENV['REGION'])
      end

      def bucket
        client.bucket(ENV['KANBANIZE_IMPORTS_BUCKET'])
      end

      def initialize(board_id, activities)
        @board_id = board_id
        @activities = activities.collect{|a| Activity.new(board_id, a)}
      end

      def new_activities
        @new_activities ||= begin
          @activities.select do |activity|
            !bucket.object(activity.key).exists?
          end 
        end
      end
      
      def store_new_activities!
        new_activities.each do |new_activity|
          store_activity(new_activity)
        end
      end

      def store_activity(activity)
        object = bucket.object(activity.key)
        object.put(body: activity.to_json)
      end

      def new_activities_event
        Request::Events::Kanbanize.new_activities_found(
          source: self.class.name, 
          board_id: @board_id, 
          activities: new_activities.collect{ |new_activity| new_activity.data }
        )
      end

    end

    class Activity

      attr_accessor :data

      def initialize(board_id, activity)
        @board_id = board_id
        @data = activity
      end

      def to_json
        data.to_json
      end

      def date
        @date ||= Date.parse(data['date'])
      end

      def year
        date.year
      end

      def month
        date.month
      end

      def day
        date.mday
      end

      def task_id
        data['task_id']
      end

      def key
        File.join("imports", "activities", year.to_s, month.to_s, day.to_s, @board_id, task_id, file)
      end

      def file
        "#{data["date"].gsub(/\s/,"__").gsub(/:/,"-")}.json"     
      end
    end
  end
end

