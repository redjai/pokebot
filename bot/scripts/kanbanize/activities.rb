require_relative 'env'
require 'service/kanbanize/import_board_activities'
require 'request/request'
require 'request/event'

event = Request::Event.new source: 'activities script', name: 'script-kanbanize-activities', version: 1.0, data: { "boardid" => "7" }
bot_request = Request::Request.new current: event

pp JSON.parse(Service::Kanbanize::ImportBoardActivities.call(bot_request))
