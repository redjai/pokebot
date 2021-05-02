$: << File.expand_path(Dir.pwd)

require 'yaml'
require 'generators/service'
require 'fileutils'

service = ARGV[0]

service_handler = File.join("handlers","#{service}.rb")
service_dir = File.join("service",service)
service_controller = File.join("service",service,"controller.rb")
service_func1 = File.join("service", service, "func1.rb")
service_spec = File.join("spec","handlers", "#{service}_spec.rb")

def write(data)
  f = File.new(data[:file], 'w')
  f.write(data[:code])
  f.close
end

files = [
  { file: service_handler, code: handler(service) },
  { file: service_dir },
  { file: service_controller, code: controller(service) },
  { file: service_func1, code: func1(service) },
  { file: service_spec, code: spec(service) }  
]

puts files.inspect

files.each do |f|
  raise "file #{f[:file]} exists" if File.exists?(f[:file])
end

files.each do |f|
  if f[:code]
    write(f)
  else
    FileUtils.mkdir(f[:file])
  end
end

