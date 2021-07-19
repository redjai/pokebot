require 'aws-sdk-s3'

module Storage
  module Kanbanize
    class ImportBucket
        
      @@resource = Aws::S3::Resource.new(region: ENV['REGION'], force_path_style: (ENV['S3_FORCE_STYLE_PATH'] == 'YES'))
  
      def bucket
        @@resource.bucket(ENV['KANBANIZE_IMPORTS_BUCKET'])
      end
    
    end
  end
end