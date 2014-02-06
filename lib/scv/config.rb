require 'yaml'

module SCV
  class Config
    attr_accessor :data

    def initialize(file_store, file_name)
      @file_store = file_store
      @file_name  = file_name

      @data = {}
      load
    end

    def load
      @data = YAML.load @file_store.fetch(@file_name) if @file_store.file? @file_name
    end

    def save
      @file_store.store @file_name, @data.to_yaml
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end
  end
end