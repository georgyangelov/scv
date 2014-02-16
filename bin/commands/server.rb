desc 'Starts a barebones HTTP server to act as a remote repo'
arg_name ''
command [:server] do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]

    server = SCV::Server.new File.join(global_options[:dir], '.scv')
    server.start
  end
end