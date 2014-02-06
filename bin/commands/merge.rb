desc 'Merges two branches to the working directory'
arg_name '<branch name>'
command :merge do |c|
  c.desc          'Abort the current merge. Resets the working dir and the next commit parents'
  c.arg_name      'abort'
  c.switch        :abort

  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository.resolve(:head, :commit)

    if options[:abort]
      repository.config['merge'] = {}
      repository.config.save

      repository.restore '.', commit

      next
    end

    raise 'No branch specified to merge from' if args.empty?

    commit_two = repository.resolve(args.first, :commit)

    raise 'There is no branch with that name' if commit_two.nil?

    merge_status = repository.merge commit, commit_two

    # Save the merged commit ids so that the next
    # commit has both as parents.
    repository.config['merge'] = {
      'parents' => [
        commit.id,
        commit_two.id,
      ]
    }
    repository.config.save

    puts "# Merged #{args.first} into #{repository.head}"
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
    else
      puts "# You can now use `scv commit` to create the merge commit"
      puts "# The next commit will have two parents"
      puts "# To abort the merge (not create a merge commit) use `scv merge --abort`"
    end
  end
end