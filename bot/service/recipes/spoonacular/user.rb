module Service
  module Recipe
    module User
      extend self

      @@dynamo_resource = nil 
      
      def recipe_ids(user_id)
        user = read(user_id)
        user.nil? ? [] : user['favourites'].collect{ |id| id.to_i }
      end

      def read(user_id)
        dynamo_resource.client.query({
          expression_attribute_values: {
            ":u1" => user_id
          },
          key_condition_expression: "user_id = :u1", 
          table_name: ENV['FAVOURITES_TABLE_NAME'],
          select: "ALL_ATTRIBUTES"
        }).items.first
      end
      
      def upsert(user_id, favourites)
        dynamo_resource.client.update_item({
          key: {
            "user_id" => user_id, 
          },  
          update_expression: 'set #favourites = :favourites',
          expression_attribute_names: {
            '#favourites': 'favourites'
          },
          expression_attribute_values: {
            ':favourites': favourites
          },
          table_name: ENV['FAVOURITES_TABLE_NAME'] 
        })
      end
      
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
