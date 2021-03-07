def recipe_search_api_event
  {"version"=>"2.0",
   "routeKey"=>"POST /messages",
   "rawPath"=>"/messages",
   "rawQueryString"=>"",
   "headers"=>
    {"accept"=>"*/*",
     "accept-encoding"=>"gzip,deflate",
     "content-length"=>"809",
     "content-type"=>"application/json",
     "host"=>"1cifazrqce.execute-api.eu-west-1.amazonaws.com",
     "user-agent"=>"Slackbot 1.0 (+https://api.slack.com/robots)",
     "x-amzn-trace-id"=>"Root=1-60435902-27925f83785be963317bebe6",
     "x-forwarded-for"=>"54.145.25.158",
     "x-forwarded-port"=>"443",
     "x-forwarded-proto"=>"https",
     "x-slack-request-timestamp"=>"1615026434",
     "x-slack-signature"=>
      "v0=d548394c1c1849233e7033f5d9296fa4c3b51cb01eddf30ff81237e4924beb5b"},
   "requestContext"=>
    {"accountId"=>"154682513313",
     "apiId"=>"1cifazrqce",
     "domainName"=>"1cifazrqce.execute-api.eu-west-1.amazonaws.com",
     "domainPrefix"=>"1cifazrqce",
     "http"=>
      {"method"=>"POST",
       "path"=>"/messages",
       "protocol"=>"HTTP/1.1",
       "sourceIp"=>"54.145.25.158",
       "userAgent"=>"Slackbot 1.0 (+https://api.slack.com/robots)"},
     "requestId"=>"bwrYchH9joEEJKQ=",
     "routeKey"=>"POST /messages",
     "stage"=>"$default",
     "time"=>"06/Mar/2021:10:27:14 +0000",
     "timeEpoch"=>1615026434737},
   "body"=>
    "{\"token\":\"HXynO313AH8R2d3AK8Rp5KPZ\",\"team_id\":\"T010JM31KJ9\",\"api_app_id\":\"A01GMRY9VDX\",\"event\":{\"client_msg_id\":\"43aa30eb-ecb7-4744-9845-5df904c98334\",\"type\":\"app_mention\",\"text\":\"<@U01FUN5L2KZ> beef rendang\",\"user\":\"U0105SZFV7U\",\"ts\":\"1615026433.000700\",\"team\":\"T010JM31KJ9\",\"blocks\":[{\"type\":\"rich_text\",\"block_id\":\"GeL\",\"elements\":[{\"type\":\"rich_text_section\",\"elements\":[{\"type\":\"user\",\"user_id\":\"U01FUN5L2KZ\"},{\"type\":\"text\",\"text\":\" beef rendang\"}]}]}],\"channel\":\"C01G6CTJU3F\",\"event_ts\":\"1615026433.000700\"},\"type\":\"event_callback\",\"event_id\":\"Ev01QL8EQXL4\",\"event_time\":1615026433,\"authorizations\":[{\"enterprise_id\":null,\"team_id\":\"T010JM31KJ9\",\"user_id\":\"U01FUN5L2KZ\",\"is_bot\":true,\"is_enterprise_install\":false}],\"is_ext_shared_channel\":false,\"event_context\":\"1-app_mention-T010JM31KJ9-C01G6CTJU3F\"}",
   "isBase64Encoded"=>false 
  }
end
