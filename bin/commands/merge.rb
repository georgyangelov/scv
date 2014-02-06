desc 'Merges two branches to the working directory'
arg_name '<branch name>'
command :merge do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository.resolve(:head, :commit)

    raise 'No branch specified to merge from' if args.empty?

    commit_two = repository.resolve(args.first, :commit)

    raise 'There is no branch with that name' if commit_two.nil?

    merge_status = repository.merge commit, commit_two

    puts "# Merged #{args[0]} into #{repository.head}"
    puts

    if merge_status[:merged].any?
      puts "# Automatic merges:"

      merge_status[:merged].each do |file|
        puts "    #{file}".yellow
      end

      puts
    end

    if merge_status[:conflicted].any?
      puts "# Conflicted files:"

      merge_status[:conflicted].each do |file|
        puts "    #{file}".red
      end

      puts
    end
  end
end