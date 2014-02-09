desc 'Sets/changes config parameters for this repository'
arg_name '[<option> [<value>]]'
command :config do |c|
  c.desc          'Delete the specified key'
  c.arg_name      'delete'
  c.switch        [:d, :delete]

  c.action do |global_options, options, args|
    repository = global_options[:repository]

    if args.empty?
      # List all config options in a `tree`-like hierarchy
      output { SCV::Formatters::Hierarchy.print(repository.config.data) }
    elsif args.size == 1
      if options[:delete]
        repository.config.delete args.first
        repository.config.save
      else
        # Print the specified option value
        value = repository.config[args.first]
        puts value unless value.nil?
      end
    else
      # Set the specified option
      repository.config[args.first] = args[1..args.size].join(' ')
      repository.config.save
    end
  end

end