require 'aws-sdk-s3'

module Service
  module Kanbanize
    module PopCommand # change this name 
      extend self

      def listen
        [ Gerty::Request::Events::Cron::Actions::POP_COMMAND ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        pop = PopCommander.new
        pop.pop(bot_request.data['folder']) do |pop_command|
          bot_request.events << Gerty::Request::Events::Cron.command_popped(source: self, action: pop_command.action, data: pop_command.data)
        end
      end


      # action: do_something
      # var1: hello
      # var2: 1234
      class PopCommand

        attr_reader :action, :data
        
        def initialize(command)
          @command = command
        end

        def hydrate!
          @data = {}
          @command.lines.each do |line|
            raw = line.split(":")
            raise "unexpected value #{line}" unless raw.length == 2
            @data[raw.first.strip] = raw.last.strip
          end
          @action = @data.delete('action')
          self
        end
      end

      class PopCommander
        
        @@resource = Aws::S3::Resource.new(region: ENV['REGION'], force_path_style: (ENV['S3_FORCE_STYLE_PATH'] == 'YES'))
    
        def bucket
          @@resource.bucket(ENV['KANBANIZE_IMPORTS_BUCKET'])
        end

        def pop(folder)
          object = first(folder)
          if object
            yield PopCommand.new(object.get.body.read).hydrate!
            object.copy_to(bucket: object.bucket_name, key: object.key.gsub(/do$/,"done"))
            object.delete
          else
            puts "no commands found in '#{folder}'"
          end
        end

        def first(folder)
          bucket.objects({prefix: folder}).find{|obj| obj.key.end_with?(".do") }
        end

      end
    end
  end
end