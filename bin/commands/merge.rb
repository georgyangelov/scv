desc 'Merges two branches to the working directory'
arg_name ''
command :merge do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository.resolve(:head, :commit)
    commit_two = repository.resolve(args[0], :commit)

    repository.merge commit, commit_two
  end
end