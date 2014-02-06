desc 'Merges two branches to the working directory'
arg_name '<branch name>'
command :merge do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository.resolve(:head, :commit)

    raise 'No branch specified to merge from' if args.empty?

    commit_two = repository.resolve(args[0], :commit)

    raise 'There is no branch with that name' if commit_two.nil?

    repository.merge commit, commit_two
  end
end