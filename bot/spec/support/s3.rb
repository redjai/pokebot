require 'aws-sdk-s3'

module SpecHelper
  module S3

    ENV['KANBANIZE_IMPORTS_BUCKET'] = 'test-import-data-bucket'
 
    @@resource ||= Aws::S3::Resource.new(region: ENV['REGION'], force_path_style: (ENV['S3_FORCE_STYLE_PATH'] == 'YES'))

    def self.exists?(key)
      bucket.object(key).exists?
    end

    def self.client
      @@resource
    end

    def self.bucket
      @@resource.bucket(ENV['KANBANIZE_IMPORTS_BUCKET'])
    end

    def self.teardown
      bucket.delete! if bucket.exists?
    end

    def self.setup
      teardown
      bucket.create
    end
  end
end
