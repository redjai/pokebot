RSpec.configure do |config|
  config.include FactoryTopic::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
