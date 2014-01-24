require 'httparty'
require 'vcs_toolkit/file_store'

module SCV

  class HTTPFileStore < VCSToolkit::FileStore
    attr_reader :base_url

    def initialize(url)
      @base_url = url.sub(/\/$/, '')
    end

    def fetch(path)
      http_response = HTTParty.get("#{base_url}/#{path}")

      case http_response.code
      when 200
        http_response.body
      when 404
        raise KeyError, "The file #{base_url}/#{path} cannot be found"
      else
        raise "Invalid status code #{http_response.code} for #{base_url}/#{path}"
      end
    end

    def store(path, content)
      http_response = HTTParty.put("#{base_url}/#{path}", {body: content})

      unless http_response.code == 200
        raise "Invalid status code #{http_response.code} for #{base_url}/#{path} (put)"
      end
    end

    def file?(path)
      http_response = HTTParty.head("#{base_url}/#{path}")

      case http_response.code
      when 200
        true
      when 404
        false
      else
        raise "Invalid status code #{http_response.code} for #{base_url}/#{path}"
      end
    end

    # These methods should not be used currently as this class
    # will only be used by the object_store.

    # def delete_file(path)
    # end

    # def delete_dir(path)
    # end

    # def directory?(path)
    # end

    # def changed?(path, blob)
    # end

    # def each_file(path='', &block)
    # end

    # def each_directory(path='', &block)
    # end
  end

end