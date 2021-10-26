require 'json'

files = Dir.glob("data/activities/**/*.json")

check = {}

files.each do |file|
  data = JSON.parse(File.open(file).read)
  key = "#{data['author']}-#{data['date']}"
  check[key] ||= 0
  check[key] += 1
end

puts check.inspect

