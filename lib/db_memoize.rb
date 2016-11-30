require 'active_record'
require 'active_support'
require 'digest'
require 'benchmark'
require 'db_memoize/version'
require 'db_memoize/value'
require 'db_memoize/model'
require 'db_memoize/railtie' if defined?(Rails)

module DbMemoize
  class << self
    attr_accessor :default_custom_key
    attr_writer :logger

    def logger
      @logger ||= ::Logger.new(STDOUT)
    end
  end
end
