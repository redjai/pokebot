require 'aws-sdk-rdsdataservice'

module Service
  module Kanbanize
    module DbMigrate
      extend self

      def call(_)
        resource = Aws::RDSDataService::Resource.new(region: ENV['REGION'])
        client = resource.client
        puts client.execute_statement({
          database: 'postgres',
          resource_arn: "arn:aws:rds:eu-west-1:154682513313:cluster:redqueen-development",
          secret_arn: "arn:aws:secretsmanager:eu-west-1:154682513313:secret:rds-db-credentials/cluster-JQWIOQ5JMHESWHSWLDLGMIQXV4/redqueen_master-3ZGPAH",
          sql: "select * from users"
        })
      end

    end
  end
end

