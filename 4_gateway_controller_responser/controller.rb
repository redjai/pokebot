require 'json'
require 'pokebot/sns'
require 'pokebot/data'

def handle(event:, context:)
  puts event

  event["Records"].each do |record|
    event_data = sqs_record_data(record)

    puts event_data

    event_data['responses'] = {text: "<@#{event_data['slack']['event']['user']}> hello from pokebot"}

    puts event_data

    topic.publish(message: event_data.to_json)
  end 
end


