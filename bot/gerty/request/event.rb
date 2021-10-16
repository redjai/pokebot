require_relative 'request'
require_relative 'context'
require 'json'

module Gerty
  module Request 
    class Event
      
      attr_reader :record, :intent

      def initialize(source:, name:, version:, data: {}, intent: false)
        @record = { 
                    'name' => name, 
                    'metadata' => 
                      { 
                        'source' => source, 
                        'version' => version, 
                        'ts' => Time.now.to_f 
                      },
                    'intent' => intent,
                    'data' => data 
                  }
      end

      def data
        @record['data']
      end

      def name
        @record['name']
      end

      def to_h
        @record.to_h
      end

    end
  end
end
