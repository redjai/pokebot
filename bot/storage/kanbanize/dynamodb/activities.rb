# PRIMARY KEY -> author + ISO datetime 
require 'aws-sdk-dynamodb'
require 'digest'
require 'date'
require 'gerty/lib/logger'

module Storage
  module Kanbanize
    module DynamoDB
      module Activities
        extend self

        def fetch(author:, dates:)
          range = dates_to_range(dates)
          dynamo_resource.client.query(
            {
              table_name: ENV['KANBANIZE_ACTIVITIES_TABLE_NAME'],
              index_name: "author_date",
              expression_attribute_values: {
                ":start" => to_d(range.first),
                ":finish" => to_d(range.last),
                ":author" => author
              },
               expression_attribute_names: {
                "#date" => "date",
                "#author" => "author"
              },
              key_condition_expression: "#author = :author AND #date BETWEEN :start AND :finish"
            }
          )
        end

        def dates_to_range(dates)
          case dates
          when :yesterday
            ((Date.today - 1)..Date.today)
          when :today
            ((Date.today)..(Date.today + 1))
          when :this_week
            ((Date.today - Date.today.wday)..(Date.today))
          when :last_week
            ((Date.today - Date.today.wday - 7)..(Date.today - Date.today.wday - 1))
          end
        end

        def to_d(date)
          date.to_datetime.iso8601
        end

        def store(client_id:, board_id:, activity:)

          monkey_key = Digest::MD5.hexdigest(activity.to_s)
 
          activity.merge!({ client_id: client_id, 
                            board_id: board_id, 
                          monkey_key: monkey_key,
                                date: DateTime.parse(activity['date']).iso8601
          })
  
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_ACTIVITIES_TABLE_NAME'],
              item: activity,
              condition_expression: "attribute_not_exists(author) AND attribute_not_exists(monkey_key)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end

        def upsert(client_id:, board_id:, activities:)
          (activities || []).select do |activity|
            store(client_id: client_id, board_id: board_id, activity: activity)
          end
        end

        # def upsert(client_id:, board_id:, activities:)
        
        #   items = activities.collect do |activity|
        #     {
        #       put_request: {
        #         item: activity.merge({ client_id: client_id, 
        #                                 board_id: board_id, 
        #                               monkey_key: Digest::MD5.hexdigest(activity.to_s),
        #                                     date: DateTime.parse(activity['date']).iso8601
        #                              })
        #       }
        #     }
        #   end
          
        #   updated = 0

        #   items.each_slice(25) do |slice| # maximum 25 items in a batch write

        #     request = {
        #       request_items: {
        #         ENV['KANBANIZE_ACTIVITIES_TABLE_NAME'] => slice
        #       },
        #       return_item_collection_metrics: "SIZE"
        #     }
        #     puts request
        #     puts dynamo_resource.client.batch_write_item(request).inspect
        #     #updated += dynamo_resource.client.batch_write_item(request)[:count]
        #   end

        #   updated
        # end

        @@dynamo_resource = nil 
        
        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
        end

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end
      end
    end
  end
end