require_relative 'task_base' 

class ArchiveTasks < TaskBase
        
  DEFAULT_PAGE_SIZE = 30

  def initialize(client_id:, board_id:, api_key:, subdomain:, date_range:)
    super(client_id: client_id, board_id: board_id, api_key: api_key, subdomain: subdomain)
    @date_range = date_range
  end

  def tasks_found_event
    if any?
      Gerty::Request::Events::Kanbanize.archived_tasks_found(
        client_id: @client_id,
        source: self.class.name, 
        board_id: @board_id, 
        tasks: taskids
      )
    end
  end

  def response
    page = 1
    tasks = []
    loop do
      body = body(page)
      result = post(kanbanize_api_key: @api_key, uri: get_all_tasks_uri, body: body)
      break if result == []
      tasks += result['task']
      break unless result["numberoftasks"].to_i > page.to_i * page_size.to_i
      page += 1
    end
    tasks 
  end

  def page_size
    ENV['PAGE_SIZE'] || DEFAULT_PAGE_SIZE
  end

  def dates
    @dates ||= date_range(@date_range)
  end

  def body(page)
    {
       boardid: @board_id,
       fromdate: dates[:from], 
       todate: dates[:to],
       container: 'archive',
       page: page
    }
  end

end