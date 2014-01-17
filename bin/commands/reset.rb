desc 'Resets files to the state they were in the current commit'
arg_name '<file> ...'
command [:reset, :restore] do |c|
  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]

    args.each do |file_path|
      repository.reset_file file_path, repository.head
    end
  end
end