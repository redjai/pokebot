require 'aws-sdk-dynamodb'


def stringify_keys(hash)
  n = hash.map do |k,v|
    v_str = if v.instance_of? Hash
              Hash[v.stringify_keys(v)]
            else
              v
            end

    [k.to_s, v_str]
  end
  Hash[n]
end

def table!(const, table)
  around do |example|
    DbSpec.create_table(table) 
    ClimateControl.modify const => table do
      example.run
    end
    DbSpec.delete_table(table)
  end
end

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
    delete_table(name)
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
      },
      'test-recipe-user-table' => {
        table_name: 'test-recipe-user-table',
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
      },
      'test-clients-table' => {
        table_name: 'test-clients-table',
        key_schema: [
          {
            attribute_name: 'team_id',
            key_type: 'HASH'  # Partition key.
          }
        ],
        attribute_definitions: [
          {
            attribute_name: 'team_id',
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
