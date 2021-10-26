$: << File.expand_path(Dir.pwd)

require 'yaml'
require 'generators/topic'

serverless = File.new('serverless.yml',"r").read

File.new("serverless.bak","w").write(serverless)

auto = YAML.load(File.new('generators/topics.yml').read)
topics = auto['sns']

topics_block = /#AUTO-BEGIN-TOPICS.+#AUTO-END-TOPICS/m

raise "unable to find topics block" unless serverless =~ topics_block

serverless.gsub!(topics_block, Generators::Resources.topics(topics))

topic_block_role_statements  = /#AUTO-BEGIN-TOPIC-ROLE-STATEMENTS.+#AUTO-END-TOPIC-ROLE-STATEMENTS/m

raise "unable to find topic role statements block" unless serverless =~ topic_block_role_statements

serverless.gsub!(topic_block_role_statements, Generators::Resources.topic_role_statements(topics))

f = File.new('serverless.yml','w')
f.write(serverless)
f.close

