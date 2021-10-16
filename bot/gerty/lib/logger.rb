require 'logger'

module Gerty
  LOGGER = Logger.new($stdout)
  case ENV['BOT_ENV']
  when 'development'
    LOGGER.level = Logger::DEBUG
  when 'test'
    LOGGER.level = Logger::WARN
  when 'production'
    LOGGER.level = Logger::INFO
  end
end
