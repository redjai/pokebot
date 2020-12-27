require 'json'
require 'pokebot/data'
require 'pokebot/slack'

def handle(event:, context:)
  puts event

  event["Records"].each do |record|
    event_data = sqs_record_data(record)
    respond_to_slack(
      channel: event_data['slack']['event']['channel'], 
      text: event_data['responses']['text']
    )
  end 
end


