$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
#ActiveRecord::Base.logger = Logger.new(STDOUT)

load File.dirname(__FILE__) + '/schema.rb'

require 'dynamic_record'
require 'database_cleaner'
require 'rspec-sqlimit'

I18n.available_locales = [:en, :fr]
Globalize.fallbacks = {:en => [:en, :fr], :fr => [:fr, :en]}

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
