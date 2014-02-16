require 'rack'

module SCV

  ##
  # This is only intended to be a very basic web server
  # that serves files from the `.scv` directory and also
  # allows uploading files there.
  #
  # Wihout! Any! Authentication!
  #
  # You do understand what this means, right?
  #
  class Server
    attr_reader :port

    def initialize(repository_path, port: 4242)
      @repository_path = repository_path
      @port            = port
    end

    def start
      Rack::Handler::WEBrick.run method(:request_handler), {Port: @port}
    end

    private

    def request_handler(env)
      request = Rack::Request.new(env)

      if request.get?
        fetch File.join(@repository_path, env['REQUEST_PATH']), request
      elsif request.put?
        store File.join(@repository_path, env['REQUEST_PATH']), request
      elsif request.head?
        head  File.join(@repository_path, env['REQUEST_PATH']), request
      else
        [405, {Allow: 'GET, POST, HEAD'}, ['Unsupported HTTP method!']]
      end
    end

    def fetch(path, request)
      return [404, {}, []] unless File.file?(path)

      content = File.read path

      [200, {'Content-Length' => content.length.to_s}, [content]]
    end

    def store(path, request)
      content = request.body.read

      File.write path, content

      [200, {}, []]
    end

    def head(path, request)
      status = File.file?(path) ? 200 : 404

      [status, {}, []]
    end
  end

end