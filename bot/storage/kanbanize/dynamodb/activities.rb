# PRIMARY KEY -> author + ISO datetime 
require 'aws-sdk-dynamodb'
require 'digest'
require 'date'

module Storage
  module Kanbanize
    module DynamoDB
      module Activities
        extend self

        def yesterday(author:)
          dynamo_resource.client.query(
            {
              expression_attribute_values: {
                ":date" => (Date.today - 1).to_s,
                ":author" => author
              },
               expression_attribute_names: {
                "#date" => "date",
                "#author" => "author"
              },
              key_condition_expression: "#date > :date AND #author = :author",
              index_name: "author_date",
              table_name: ENV['KANBANIZE_ACTIVITIES_TABLE_NAME'], 
            }
          )
        end

        def upsert(client_id:, board_id:, activities:)
        
          items = activities.collect do |activity|
            {
              put_request: {
                item: activity.merge({ client_id: client_id, 
                                        board_id: board_id, 
                                      monkey_key: Digest::MD5.hexdigest(activity.to_s),
                                            date: DateTime.parse(activity['date']).iso8601
                                     })
              }
            }
          end
          
          items.each_slice(25) do |slice| # maximum 25 items in a batch write

            request = {
              request_items: {
                ENV['KANBANIZE_ACTIVITIES_TABLE_NAME'] => slice
              }
            }
            
            dynamo_resource.client.batch_write_item(request)
          end
        end

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