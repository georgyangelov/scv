desc 'Merges two branches to the working directory'
arg_name '<branch name>'
command :merge do |c|
  c.desc          'Abort the current merge. Resets the working dir and the next commit parents'
  c.arg_name      'abort'
  c.switch        :abort

  c.desc          'Squashes the changes to a single commit. The next commit will have one parent'
  c.arg_name      'squash'
  c.switch        :squash

  c.desc          'Prevents scv merge from creating a merge commit automatically'
  c.arg_name      'no-commit'
  c.switch        :'no-commit'

  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository[:head, :commit]

    if options[:abort]
      repository.config['merge'] = {}
      repository.config.save

      repository.restore '.', commit

      next
    end

    raise 'No branch specified to merge from' if args.empty?

    commit_two = repository[args.first, :commit]

    raise 'There is no branch with that name' if commit_two.nil?

    merge_status = repository.merge commit, commit_two
    parents      = [commit.id, commit_two.id]

    if not options[:squash] or options[:'no-commit']
      # Save the merged commit ids so that the next
      # commit has both as parents.
      repository.config['merge'] = {
        'parents' => parents
      }
      repository.config.save
    end

    puts "# Merged #{args.first} into #{repository.head}"
    puts

    status = SCV::Formatters::MergeReport.format merge_status
    puts status

    unless merge_status[:conflicted].any?

      if options[:'no-commit']
        puts "# You can now use `scv commit` to create the merge commit"
        puts "# The next commit will have two parents" unless options[:squash]
        puts "# To abort the merge (not create a merge commit) use `scv merge --abort`"
      elsif merge_status[:merged].any?
        unless repository.config['author']
          raise 'Cannot create merge commit. Please specify default author'
        end

        commit_message = "Merge #{args.first} into #{repository.head}
The merge commits are #{commit.id} and #{commit_two.id}

#{status}"

        repository.commit commit_message,
                          repository.config['author'],
                          DateTime.now,
                          parents: parents,
                          ignore: [/^\.|\/\./]

        puts "# Created merge commit #{repository[:head, :commit].id.yellow}"
      else
        puts "# Nothing to merge"
      end
    end
  end
end