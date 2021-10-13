require 'aws-sdk-rdsdataservice'

#  sls invoke -f kanbanize_util --stage development -d "{\"action\":\"db-migrate\",\"migration\":\"1\",\"klazz\":\"CreateHistoriesTable\",\"direction\":\"up\"}"

class String
  def camel_case
    self.split('_').collect(&:capitalize).join
  end
end

module Service
  module Kanbanize
    module DbMigrate
      extend self

      def call(bot_request)
        migration = bot_request.data['migration']
        path = File.join("storage","kanbanize","postgres","migrations","#{migration}_*.rb")
        file = Dir.glob(path).first

        raise "cannot find a migration starting with '#{migration}_'" unless file
        require file

        klazz = Migrations.const_get(bot_request.data['klazz'])
        direction = (bot_request.data['direction'] || :up)

        resource = Aws::RDSDataService::Resource.new(region: ENV['REGION'])
        
        resource.client.execute_statement({
          database: ENV['KANBANIZE_DB_NAME'],
          resource_arn: ENV['KANBANIZE_DB_CLUSTER'],
          secret_arn: ENV['KANBANIZE_DB_SECRET_ARN'],
          sql: klazz.new.send(direction.to_sym)
        })
      end

    end
  end
end
