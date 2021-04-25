require 'yaml'
require 'bundler/inline'
require_relative '../generators/topic'

serverless = File.new('serverless.yml').read
auto = YAML.load(File.new('generators/auto.yml').read)
topics = auto['topics']

topics_block = /#AUTO-BEGIN-TOPICS.+#AUTO-END-TOPICS/m

raise "unable to find topics block" unless serverless =~ topics_block

serverless.gsub!(topics_block, Generators::Resources.topics(topics))

puts serverless

f = File.new('serverless.yml','w')
f.write(serverless)
f.close

puts "updated SNS/SQS Topoc Resources."
puts "if you have added a new Topic then don't forget to allow the iamRole to publish"
