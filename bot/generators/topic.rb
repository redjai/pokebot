class String

  def camel_case
    self.split('_').collect(&:capitalize).join
  end

end

module Generators
  module Resources
  extend self

    def topics(topics)
      [].tap do |str|
        str << header('topics')
        topics.each do |topic, queues|
          str << topic(topic)
          str << topic_queues(topic, queues)
        end

        str << footer('topics')
      end.join("\n\n")
    end

    def topic_role_statements(topics)
      [].tap do |str|
        str << header('topic-role-statements')

        topics.each do |topic, queues|
          str << topic_role_statement(topic)
        end

        str << footer('topic-role-statements')
      end.join("\n\n")
    end

    def topic_role_statement(topic)
%{    # ALLOW THE iamRole TO PUBLISH TO THE '#{topic}' SNS Topic
    - Effect: "Allow"
      Action:
        - "SNS:Publish"
      Resource: !Ref #{topic.camel_case}SnsTopic # !Ref returns the ARN of SNS topic in the resources element below:
    }
    end

    def header(name)
  %{#AUTO-BEGIN-#{name.upcase}
    # IMPORTANT !!!!!!! 
    # Any content between here and AUTO-END-#{name.upcase} will be overwritten.
    }
    end

    def footer(name)
%{    #AUTO-END-#{name.upcase}}
    end
  
    def topic(topic)
     %{
    #### AUTO GENERATED TOPIC - '#{topic}' 
    #################################
    #{topic.camel_case}SnsTopic:
      Type: AWS::SNS::Topic
      Properties:
        TopicName: ${self:service}-${self:provider.stage}-#{topic}
     }
    end

    def topic_queues(topic, queues)
      queues.collect do |queue|
        queue(topic, queue)
      end.join("\n\n")
    end

    def queue(topic, queue)
      %{
    #### AUTO GENERATED QUEUE - '#{queue}'
    #{topic.camel_case}To#{queue.camel_case}SqsQueue:
      Type: AWS::SQS::Queue
      Properties:
        QueueName: ${self:service}-${self:provider.stage}-sns-#{topic}-to-sqs-#{queue}
    
    #### AUTO GENERATED - ATTACH '#{topic}' TOPIC to '#{queue}' QUEUE
    #{topic.camel_case}To#{queue.camel_case}Subscription:
      Type: AWS::SNS::Subscription
      Properties:
        TopicArn: !Ref #{topic.camel_case}SnsTopic
        Endpoint: !GetAtt
          - #{topic.camel_case}To#{queue.camel_case}SqsQueue
          - Arn
        Protocol: sqs
      DependsOn:
        - #{topic.camel_case}SnsTopic
        - #{topic.camel_case}To#{queue.camel_case}SqsQueue
    
    #### AUTO GENERATED - ALLOW '#{topic}' TOPIC to send messages to '#{queue}' QUEUE
    SnS#{topic.camel_case}ToSQS#{queue.camel_case}SqsQueuePolicy:
      Type: AWS::SQS::QueuePolicy
      Properties:
        PolicyDocument:
          Version: "2012-10-17"
          Statement:
            - Sid: "allow-sns-#{topic}"
              Effect: Allow
              Principal: "*"
              Resource: !GetAtt
                - #{topic.camel_case}To#{queue.camel_case}SqsQueue
                - Arn
              Action: "SQS:SendMessage"
              Condition:
                ArnEquals:
                  "aws:SourceArn": !Ref #{topic.camel_case}SnsTopic 
        Queues:
          - Ref: #{topic.camel_case}To#{queue.camel_case}SqsQueue
      DependsOn:
        - #{topic.camel_case}To#{queue.camel_case}Subscription
      }
    end
  end
end
