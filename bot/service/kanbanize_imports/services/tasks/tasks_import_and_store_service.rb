require 'date'
require 'aws-sdk-s3'

require 'gerty/request/events/kanbanize'
require 'gerty/request/events/insights'

require 'storage/dynamodb/team'

require_relative '../../storage/tasks'
require_relative '../../lib/api'
require_relative '../../lib/task_data'

# this service imports task details for any new activities found that day
module Service
  module Kanbanize
    module ImportTasks
      extend self
      extend Service::Kanbanize::Api
      extend ::Storage::DynamoDB::Team                                  
      def listen
        [
          Gerty::Request::Events::Kanbanize::TASKS_FOUND,
          Gerty::Request::Events::Kanbanize::ARCHIVED_TASKS_FOUND
        ]
      end

      def broadcast
        %w( insights )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        get_teams.each do |team|
          tasks = import_tasks(bot_request, team)
          store_tasks(tasks)
          broadcast_movements(bot_request, tasks)
        end
      end

      def import_tasks(bot_request, team)
      
        collection = bot_request.data['activities'] ||  bot_request.data['tasks']
        
        ids = collection.collect do |activity|
          activity['taskid']
        end.uniq # lets not import the same task multiple times if there is more than one activity.

        uri = uri(subdomain: team.subdomain, function: :get_task_details)  

        response = post(
          kanbanize_api_key: team.kanbanize_api_key, 
          uri: uri,
          body: {
            board_id: bot_request.data['board_id'],
            taskid: ids,
            history: 'yes'
          } 
        )

        (response.is_a?(Hash) ? [response] : response).collect do |task_data|
          Service::Kanbanize::TaskData.new(team_id: team.team_id, kanbanize_data: task_data)
        end
      end

      def store_tasks(tasks)
        tasks.each do |task_data|
          Service::Kanbanize::Storage::Task.upsert(task_data)
        end
      end

      def broadcast_movements(bot_request, tasks)
        movements = tasks.collect do |task_data|
          task_data.movements.collect do |movement|
            movement.to_h
          end
        end.flatten

        bot_request.events << Gerty::Request::Events::Insights.movements_found(
          source: self.class.name, 
          movements: movements
        )
      end

    end
  end
end
