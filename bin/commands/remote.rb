desc 'A set of commands to manage remotes and push/pull to them.'
arg_name ''
command :remote do |c|

  c.desc 'Add a remote'
  c.arg_name '<remote name> <remote HTTP url>'
  c.command [:add, :new] do |add|
    add.action do |global_options, options, args|
      raise 'Please specify remote name and address' unless args.size == 2

      name = args[0]
      url  = args[1]

      repository = global_options[:repository]
      repository.config['remotes'] = {} unless repository.config['remotes']

      raise 'There is already a remote with that name' if repository.config['remotes'].key? name

      repository.config['remotes'][name] = {
        'url' => url
      }
      repository.config.save
    end
  end

  c.desc 'Delete a remote'
  c.arg_name '<remote name>'
  c.command [:delete, :remove] do |remove|
    remove.action do |global_options, options, args|
      raise 'Please specify remote name' unless args.size == 1

      name = args[0]

      repository = global_options[:repository]

      unless repository.config['remotes'] and repository.config['remotes'].key? name
        raise 'There is no remote with that name'
      end

      repository.config['remotes'].delete name
      repository.config.save
    end
  end

  c.desc 'Push local history to remote'
  c.arg_name '<remote> <local branch> [<remote branch>]'
  c.command :push do |push|
    push.action do |global_options, options, args|
      raise 'Please specify remote name and local branch' unless args.size >= 2

      repository = global_options[:repository]

      remote_name  = args[0]
      local_branch = args[1]

      raise 'There is no remote with this name' unless repository.config['remotes'][remote_name]
      raise 'There is no branch with this name' unless repository[local_branch]

      if args.size > 2
        remote_branch = args[2]
      else
        remote_branch = local_branch
      end

      remote_file_store   = SCV::HTTPFileStore.new repository.config['remotes'][remote_name]['url']
      remote_object_store = SCV::ObjectStore.new   remote_file_store

      repository.push remote_object_store, local_branch, remote_branch
    end
  end

  c.desc 'Fetch remote history objects to local branch. Does not do merging, only Fast-Forward'
  c.arg_name '<remote> <remote branch> [<local branch>]'
  c.command :fetch do |fetch|
    fetch.action do |global_options, options, args|
      raise 'Please specify remote name and remote branch' unless args.size >= 2

      repository = global_options[:repository]

      remote_name   = args[0]
      remote_branch = args[1]

      if args.size > 2
        local_branch = args[2]
      else
        local_branch = remote_branch
      end

      unless repository[local_branch]
        # There is no local branch with this name, so create it
        repository.set_label local_branch, nil
      end

      unless repository.config['remotes'] and repository.config['remotes'][remote_name]
        raise 'There is no remote with this name'
      end

      remote_file_store   = SCV::HTTPFileStore.new repository.config['remotes'][remote_name]['url']
      remote_object_store = SCV::ObjectStore.new   remote_file_store

      repository.fetch remote_object_store, remote_branch, local_branch
    end
  end

  c.desc 'Pull remote history objects to local branch. Merges automatically'
  c.arg_name '<remote> <remote branch> [<local branch>]'
  c.command :pull do |pull|
    pull.action do |global_options, options, args|
      raise 'Please specify remote name and remote branch' unless args.size >= 2

      repository = global_options[:repository]

      remote_name   = args[0]
      remote_branch = args[1]

      if args.size > 2
        local_branch = args[2]
      else
        local_branch = remote_branch
      end

      unless repository[local_branch]
        # There is no local branch with this name, so create it
        repository.set_label local_branch, nil
      end

      raise 'There is no remote with this name' unless repository.config['remotes'][remote_name]

      remote_file_store   = SCV::HTTPFileStore.new repository.config['remotes'][remote_name]['url']
      remote_object_store = SCV::ObjectStore.new   remote_file_store

      # Step 1: Fetch to another branch
      temp_branch = "#{remote_name}~#{remote_branch}"

      # Create the temp branch if not existing
      repository.set_label temp_branch, nil unless repository[temp_branch]

      repository.fetch remote_object_store, remote_branch, temp_branch

      # Step 2: Merge temp_branch into local_branch
      dest_commit   = repository[temp_branch, :commit]
      source_commit = repository[local_branch, :commit]
      merge_status  = repository.merge source_commit, dest_commit

      # Save the merged commit ids so that the next
      # commit has both as parents.
      repository.config['merge'] = {
        'parents' => [
          source_commit.id,
          dest_commit.id,
        ]
      }
      repository.config.save

      SCV::Formatters::MergeReport.print merge_status
    end
  end

end