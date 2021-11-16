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
              data = {}

              activities.sort_by{ |activity| activity['date'] }.collect do |activity|
                task = tasks.find{ |task| task['taskid'] == activity['taskid'] }
                { activity: activity, task: task }
              end.each do |row|
                data[row[:task]] ||= []
                data[row[:task]] << row[:activity]
              end

              data.each do |task, activities|
                blocks << text_section("_*#{truncate(task['title'],100)}:*_")
                text = activities.collect do |activity|
                  "* • #{d_o_w(Date.parse(activity['date']))}* #{activity['event']}: #{truncate(activity['text'], 100)}"
                end.join("\n")
                blocks << text_section(text)
                blocks << actions(
                    button_element(text: "View Task", 
                                  value: task['taskid'], 
                                options: { url: link(task) })
                  )
                blocks << divider_block
              end
              blocks
            end
      
            def d_o_w(date)
              case date.wday
              when 0 
                '[sun]'
              when 1
                '[mon]'
              when 2
                '[tue]'
              when 3
                '[wed]'
              when 4
                '[thu]'
              when 5
                '[fri]'
              when 6
                '[sat]'
              end
            end

            def ago_section(ago)
              text_section("*#{ago}*")
            end

            def link(task)
              "https://livelinktechnology.kanbanize.com/ctrl_board/#{task['boardid']}/cards/#{task['taskid']}/details/"
            end
    
            def activity_section(activity)
              text_section()
            end

            def truncate(text, max=25)
              if text.length > max - 3
                "#{text.slice(0,max - 3)}..."
              else
                text 
              end
            end
          end
        end
      end
    end
  end
end


