require 'date'
require 'aws-sdk-rdsdataservice'
require_relative 'net/api'
require 'storage/kanbanize/s3/task'
require 'storage/kanbanize/postgres/column_durations'

module Service
  module Kanbanize
    module TaskColumnDuration # change this name 
      extend self
  
      def call(bot_request)

        return unless bot_request.data['archived']

        client_id = bot_request.data['client_id']
        board_id = bot_request.data['board_id']

        fetcher = Storage::Kanbanize::TaskFetcher.new(
          client_id: client_id,
          board_id: board_id,
          archived: bot_request.data['archived'] == 'yes'
        )

        bot_request.data['tasks'].each do |task|
          s3task = fetcher.fetch(task['task_id'])

          next unless s3task

          history_details = s3task['historydetails'].collect do |detail|
            Storage::Kanbanize::HistoryDetail.new(detail)
          end

          durations = Storage::Postgres::ColumnDurations.new(
                                                               client_id: client_id, 
                                                               board_id: board_id,
                                                               workflow: s3task['workflow'],
                                                               task_id: task['task_id'], 
                                                               history_details: history_details
                                                            )

          durations.store! if durations.valid?

        end
      end
    end
  end
end