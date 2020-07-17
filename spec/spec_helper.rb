ENV['TZ']='UTC'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_record'
require 'database_cleaner'
require 'factory_bot'
require 'yaml'

unless ENV['SKIP_COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    minimum_coverage 50
  end
end

require "db_memoize"
require './spec/support/bicycle'


project_root = File.expand_path("../../", __FILE__)
db_config = YAML.load_file("#{project_root}/config/database.yml").symbolize_keys

ActiveRecord::Base.establish_connection(db_config)

load File.dirname(__FILE__) + '/schema.rb'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.run_all_when_everything_filtered = true
  config.filter_run focus: (ENV['CI'] != 'true')
  config.example_status_persistence_file_path = '.rspec.data'

  config.before(:suite) do
    FactoryBot.lint
    FactoryBot.find_definitions
  end

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
