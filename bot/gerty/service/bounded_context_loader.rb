module Gerty
  module Service
    class BoundedContextLoader

      attr_accessor :event_source_arn

      def initialize(**opts)
        @event_source_arn = opts[:event_source_arn]
        @root = opts[:root] || 'service'
        @name = opts[:name]
      end

      def name
        @name ||= begin
          raise "cannot derive bounded context name from nil arn" unless event_source_arn
          event_source_arn_to_name(event_source_arn)
        end
      end

      def event_source_arn_to_name(event_source_arn)
        match_data = event_source_arn.match(/sqs-(.+)$/)
        raise "cannot derive bounded context name from sqs queue name in '#{event_source_arn}'" unless match_data
        match_data[1].gsub("-","_")
      end

      def load!
        Gerty::LOGGER.debug("searching in #{bounded_context_folder}")
        bounded_context_files.each do |file|
          Gerty::LOGGER.debug("found service file #{file}")
          raise "cannot load service #{file}" unless File.exists?(file)
          require file
        end
        if bounded_context_files.empty?
          Gerty::LOGGER.debug("FOUND NO SERVICE FILES IN: #{bounded_context_folder}")
        end
      end

      def bounded_context_folder
        File.join(@root, name)
      end

      def bounded_context_files
        ["*_service.rb", "*_sentry.rb"].collect do |suffix|
          Dir.glob(File.join(bounded_context_folder,"services","**", suffix))
        end.flatten
      end

    end
  end
end