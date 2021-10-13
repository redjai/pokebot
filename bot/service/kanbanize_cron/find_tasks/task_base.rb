class TaskBase
  include Service::Kanbanize::Api

  def initialize(client_id:, board_id:, api_key:, subdomain:)
    @client_id = client_id
    @board_id = board_id
    @api_key = api_key
    @subdomain = subdomain
  end

  def get_all_tasks_uri
    uri(subdomain: @subdomain, function: :get_all_tasks)
  end

  def taskids
    @task_ids ||= response.collect{ |task| { "taskid" => task['taskid']} }
  end

  def any?
    taskids.any?
  end
end