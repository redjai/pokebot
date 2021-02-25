require 'aws-sdk-dynamodb'

ENV['DYNAMO_ENDPOINT'] = 'https://localhost:4566' 
ENV['VERIFY_SSL_PEER'] = 'false'

module DbSpec
  extend self
  
  @@resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'], endpoint: 'https://localhost:4566', ssl_verify_peer: false)

  def table_exists?(name)
    !@@resource.tables.select{|t| t.name == name }.empty?
  end

  def delete_table(name)
    @@resource.table(name).delete if table_exists?(name)
  end

  def create_table(name)
    @@resource.create_table(user_table_definitions[name]) unless table_exists?(name)
  end

  def count(name)
    @@resource.table(name).item_count
  end

  def item(table, key)
    @@resource.table(table).get_item(key: key).item
  end

  def user_table_definitions
    {
      'test-user-table' => {
        table_name: 'test-user-table',
        key_schema: [
          {
            attribute_name: 'user_id',
            key_type: 'HASH'  # Partition key.
          }
        ],
        attribute_definitions: [
          {
            attribute_name: 'user_id',
            attribute_type: 'S'
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10
        }
      }
    }
  end
end
