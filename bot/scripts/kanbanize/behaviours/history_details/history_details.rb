require_relative 'history_detail'
require_relative 'block'
require_relative 'comment'
require_relative 'custom_field_added'
require_relative 'custom_field_deleted'
require_relative 'custom_field_changed'
require_relative 'deleted'
require_relative 'exceeded_limit'
require_relative 'mention'
require_relative 'notification'
require_relative 'reached_limit'
require_relative 'stickers'
require_relative 'transition'
require_relative 'unarchive'
require_relative 'update'
require_relative 'work'
require 'logger'

module HistoryDetails

  def self.build(history_detail)
    klazz(history_detail['eventtype']).new(history_detail)
  end

  def self.klazz(event_type)
    const_get(event_type.gsub(/s$/,"").split(" ").collect do |bit|
      bit.capitalize
    end.join(""))
  end

  class Collection < Array

    LOGGER = Logger.new("/tmp/gerty-history-details.log")

    def works
      @works ||= begin
        works = []
        if created.first
          works << Work.new(entry: created.first, exit: column_movements.first)
        end
        column_movements.each_cons(2) do |entry, exit| 
          work = Work.new(entry: entry, exit: exit)
          if work.valid?
            works << work 
          else
            LOGGER.info("work #{work.entry.class} #{work.exit.class}[#{work.entry.to_name}] does not equal [#{work.exit.from_name}]")
          end
        end
        if archived.first
          works << Work.new(entry: column_movements.last, exit: archived.first)
        end
        works
      end
    end

    def get(type:)
      select do |history_detail|
        history_detail.event_type == type
      end.sort_by{ |history_detail| history_detail.entry_date }
    end

    def section_entry(section)
      entry_work = works.find do |work|
        work.section == section
      end
      entry_work.entry.entry_date if entry_work
    end

    def section_exit(section)
      exit_works = works.select do |work|
        work.section == section
      end
      exit_works.last.exit.entry_date unless exit_works.empty?
    end

    def movements
      @movements ||= begin
        movements = column_movements
        return [] if movements.empty?
        movements << created if created
        movements << archived if archived
        movements.flatten.sort_by{ |history_detail| history_detail.entry_date }
      end
    end

    def column_movements
      @column_movements ||= get(type: 'Transitions').select{ |transition| transition.column_movement? }
    end

    def comments
      get(type: 'Comments')
    end

    def blocked
      select{ |history_detail| history_detail.is_a?(Block) }
    end

    def subtasks
      get(type: 'Updates').select{ |update| update.history_event == 'Subtask  created'} #GRRR! API has two spaces...
    end

    def exceeded_wip_limit
      select{ |history_detail| history_detail.is_a?(ExceededLimit) }
    end

    def mentions
      select{ |history_detail| history_detail.is_a?(Mention) }
    end

    def indexed_column_movements
      column_movements.select{ |movement| movement.indexed? }
    end

    def created
      @created ||= begin
        select{ |history_detail| history_detail.history_event == 'Task created' }
      end
    end

    def archived
      @archived ||= begin
        select{ |history_detail| history_detail.history_event == 'Task archived' }
      end
    end

  end

end