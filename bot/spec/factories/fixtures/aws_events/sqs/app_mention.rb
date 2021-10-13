module Fixtures
  module AwsEvents
    def self.app_mention
  {"Records"=>
    [{"messageId"=>"be85f8ca-bc55-4a62-a5b3-6d54c1a153de",
      "receiptHandle"=>
      "AQEBoEas6/YhKOIdb1SOaZEw9RswposSbbH8x5Avv2MiCtlOn88T7eOTQAVKBYk4l0/b+en2K2A5l+bo5SeiBYgHE5rZviaGx3zf6uX2xCzUN73iY+drTV2IFn5BiDpGYM1dTUH5zeM1/inozA44+7apD5bRfQlNCC6BW5EmlUbC+Pj7v54sWnIr6PjQ05cgBpi1+TSib9abKVh2gY7kjmTPKhnNeIcsKxLrffdkFjgq+fk+0+eRRe66UyLb6xvOREi90/C6uO9ZKGJujvYM40pGPLM3yTqoi0SpyhjAiGQCqjPq6LN0wfFYWejDar1HSol7934TIblPXMwWszwY4DXu6JGpCxTYu/rwoeWxvs73mh2TprITXchGTl6fiPi5hXTZ2ZPILBOsK4pGu/9ltpuqYFtA6Spr2SVkMSUijVhXq2Q=",
      "body"=>
      "{\n" +
      "  \"Type\" : \"Notification\",\n" +
      "  \"MessageId\" : \"81d5fc6d-079b-590f-8189-a5b1afe5be9a\",\n" +
      "  \"TopicArn\" : \"arn:aws:sns:eu-west-1:154682513313:gerty-development-messages\",\n" +
      "  \"Message\" : \"{\\\"current\\\":{\\\"name\\\":\\\"app_mention\\\",\\\"metadata\\\":{\\\"source\\\":\\\"messages\\\",\\\"version\\\":1.0,\\\"ts\\\":1633855038.2497616},\\\"intent\\\":false,\\\"data\\\":{\\\"text\\\":\\\"hello\\\"}},\\\"trail\\\":[{\\\"name\\\":\\\"slack-event-api-request\\\",\\\"metadata\\\":{\\\"source\\\":\\\"slack-event-api\\\",\\\"version\\\":1.0,\\\"ts\\\":1633855038.2496648},\\\"intent\\\":false,\\\"data\\\":{\\\"token\\\":\\\"HXynO313AH8R2d3AK8Rp5KPZ\\\",\\\"team_id\\\":\\\"T010JM31KJ9\\\",\\\"api_app_id\\\":\\\"A01GMRY9VDX\\\",\\\"event\\\":{\\\"client_msg_id\\\":\\\"9cc56fbc-fbdb-4256-92da-3d769c0340ed\\\",\\\"type\\\":\\\"app_mention\\\",\\\"text\\\":\\\"<@U01FUN5L2KZ> hello\\\",\\\"user\\\":\\\"U0105SZFV7U\\\",\\\"ts\\\":\\\"1633855036.000200\\\",\\\"team\\\":\\\"T010JM31KJ9\\\",\\\"blocks\\\":[{\\\"type\\\":\\\"rich_text\\\",\\\"block_id\\\":\\\"kJx\\\",\\\"elements\\\":[{\\\"type\\\":\\\"rich_text_section\\\",\\\"elements\\\":[{\\\"type\\\":\\\"user\\\",\\\"user_id\\\":\\\"U01FUN5L2KZ\\\"},{\\\"type\\\":\\\"text\\\",\\\"text\\\":\\\" hello\\\"}]}]}],\\\"channel\\\":\\\"C01G6CTJU3F\\\",\\\"event_ts\\\":\\\"1633855036.000200\\\"},\\\"type\\\":\\\"event_callback\\\",\\\"event_id\\\":\\\"Ev02H2J30H46\\\",\\\"event_time\\\":1633855036,\\\"authorizations\\\":[{\\\"enterprise_id\\\":null,\\\"team_id\\\":\\\"T010JM31KJ9\\\",\\\"user_id\\\":\\\"U01FUN5L2KZ\\\",\\\"is_bot\\\":true,\\\"is_enterprise_install\\\":false}],\\\"is_ext_shared_channel\\\":false,\\\"event_context\\\":\\\"4-eyJldCI6ImFwcF9tZW50aW9uIiwidGlkIjoiVDAxMEpNMzFLSjkiLCJhaWQiOiJBMDFHTVJZOVZEWCIsImNpZCI6IkMwMUc2Q1RKVTNGIn0\\\"}}],\\\"context\\\":{\\\"slack_id\\\":\\\"U0105SZFV7U\\\",\\\"channel\\\":\\\"C01G6CTJU3F\\\",\\\"message_ts\\\":null,\\\"response_url\\\":null,\\\"trigger_id\\\":null,\\\"private_metadata\\\":null}}\",\n" +
      "  \"Timestamp\" : \"2021-10-10T08:37:18.296Z\",\n" +
      "  \"SignatureVersion\" : \"1\",\n" +
      "  \"Signature\" : \"rdqvD04aU6Cc4t89bBz+13GIB6Tl9HOYxEdAs49se2tmJApFGeMmZSIR/L0+2DxYeSG9nY+i6HT+HWEmPhUbuVT0Uw5CgWjce1mEeL2yweDv8NRaRUeJXkpt8LZTIp0wEfOF2P/KF8WscOgqBtH2xRjR5Jq4tabJ1ZzPaID/Y9mSx9X9lc0JiBCbbyc8QR8G0i68rGmD0uo23oFn88rJCHOEV/hlH/qssSdg1kfpywPhKQm1MrzJV7A6l739CWK3EuUN6+HryRJcQ0jxXZZQVyMuB0ktHXoSTgUc4IgZoiDDV45+y75DAhW6DkD/bH6Xa7tJg4aXPZBpOneQr28leA==\",\n" +
      "  \"SigningCertURL\" : \"https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-7ff5318490ec183fbaddaa2a969abfda.pem\",\n" +
      "  \"UnsubscribeURL\" : \"https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:154682513313:gerty-development-messages:1c1cc513-7d25-4b2e-9108-39127d34db09\"\n" +
      "}",
      "attributes"=>
      {"ApproximateReceiveCount"=>"1",
        "SentTimestamp"=>"1633855038334",
        "SenderId"=>"AIDAISMY7JYY5F7RTT6AO",
        "ApproximateFirstReceiveTimestamp"=>"1633855038338"},
      "messageAttributes"=>{},
      "md5OfBody"=>"2872b42c7ea4152d5e005e0ad5a7284d",
      "eventSource"=>"aws:sqs",
      "eventSourceARN"=>
      "arn:aws:sqs:eu-west-1:154682513313:gerty-development-sns-messages-to-sqs-intent",
      "awsRegion"=>"eu-west-1"}]}
    end
  end
end