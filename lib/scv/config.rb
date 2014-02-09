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
      hash, key = resolve_key key
      hash[key]
    end

    def []=(key, value)
      hash, key = resolve_key key, create: true
      hash[key] = value
    end

    def delete(key)
      hash, key = resolve_key key, create: false
      hash.delete key
    end

    private

    def resolve_key(hash=@data, key, create: false)
      key, rest = key.split '.', 2

      if rest.nil?
        [hash, key]
      else
        hash[key] = {} if create and not hash.key? key

        resolve_key hash[key], rest, create: create
      end
    end
  end
end