require_relative '../../blocks/builder'

module Service
  module Responder
    module Slack
      module Views
        module Insights
          class Developer
          include Service::Responder::Slack::BlockBuilder

            def initialize(bot_request)
              @bot_request = bot_request
            end

            def days_ago(date)
              if date == Date.today
                'today'
              elsif date == Date.today - 1
                'yesterday'
              else
                 "#{(Date.today - date).to_i} days ago"
              end
            end

            def activities
              @bot_request.data['activities']
            end

            def tasks
              @bot_request.data['tasks']
            end

            def insight_blocks
              blocks = []
              dated = {}
              activities.sort_by{ |activity| activity['date'] }.collect do |activity|
                task = tasks.find{ |task| task['taskid'] == activity['taskid'] }
                { activity: activity, task: task }
              end.each do |row|
                ago = days_ago(Date.parse(row[:activity]['date']))
                dated[ago] ||= []
                dated[ago] << row
              end
              dated.each do |ago, rows|
                blocks << ago_section(ago)
                rows.each do |row|
                  blocks << row_section(row)
                end
              end
              blocks
            end

            def ago_section(ago)
              text_section(ago)
            end
    
            def row_section(row)
              text_section("#{row[:activity]['event']}, #{row[:activity]['text']} #{row[:task]['title']}")
            end
          end
        end
      end
    end
  end
end


