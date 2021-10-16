require_relative 'env'
require 'service/kanbanize/get_all_tasks'
require 'gerty/request/request'
require 'gerty/request/event'

event = Request::Event.new source: 'activities script', name: 'script-kanbanize-activities', version: 1.0, data: { "boardid" => "7" }
bot_request = Request::Request.new current: event

pp JSON.parse(Service::Kanbanize::GetAllTasks.call(bot_request))
