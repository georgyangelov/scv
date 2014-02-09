desc 'Resets files to the state they were in the specified commit'
arg_name '<file> ...'
command [:restore] do |c|
  c.desc          'Use this specify which commit should be the used as reference'
  c.arg_name      'source'
  c.default_value 'head'
  c.flag          [:s, :source]

  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository[options[:source], :commit]

    args.each do |path|
      repository.restore path, commit
    end
  end
end