$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
#ActiveRecord::Base.logger = Logger.new(STDOUT)

require 'dynamic_record'

load File.dirname(__FILE__) + '/schema.rb'

require 'database_cleaner'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
