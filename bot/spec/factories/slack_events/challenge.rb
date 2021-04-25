def slack_challenge(args)
  {"version"=>"2.0", 
   "routeKey"=>"POST /messages", 
   "rawPath"=>"/messages", 
   "rawQueryString"=>"", 
   "headers"=>{
     "accept"=>"*/*", 
     "accept-encoding"=>"gzip,deflate", 
     "content-length"=>"129", 
     "content-type"=>"application/json", 
     "host"=>"3z2irg9494.execute-api.eu-west-1.amazonaws.com", 
     "user-agent"=>"Slackbot 1.0 (+https://api.slack.com/robots)", 
     "x-amzn-trace-id"=>"Root=1-6085af22-2b1340d252f084c35961934f", 
     "x-forwarded-for"=>"3.238.73.141", 
     "x-forwarded-port"=>"443", 
     "x-forwarded-proto"=>"https", 
     "x-slack-request-timestamp"=>"1619373858", 
     "x-slack-signature"=>"v0=d9bc53e3e08cfa18556bd1a57cfc720016b754f62c7f9b2249692d81b6f7eea0"
   }, 
   "requestContext"=>{
     "accountId"=>"154682513313", 
     "apiId"=>"3z2irg9494", 
     "domainName"=>"3z2irg9494.execute-api.eu-west-1.amazonaws.com", 
     "domainPrefix"=>"3z2irg9494", 
     "http"=>{
       "method"=>"POST", 
       "path"=>"/messages", 
       "protocol"=>"HTTP/1.1", 
       "sourceIp"=>"3.238.73.141", 
       "userAgent"=>"Slackbot 1.0 (+https://api.slack.com/robots)"
     }, 
     "requestId"=>"eWhNbhmMDoEEJ5Q=", 
     "routeKey"=>"POST /messages", 
     "stage"=>"$default", 
     "time"=>"25/Apr/2021:18:04:18 +0000", 
     "timeEpoch"=>1619373858616
   }, 
   "body"=>"{\"token\":\"HXynO313AH8R2d3AK8Rp5KPZ\",\"challenge\":\"#{args[:challenge]}\",\"type\":\"url_verification\"}", 
   "isBase64Encoded"=>false
  }
end
