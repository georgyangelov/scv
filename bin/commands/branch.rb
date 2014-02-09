desc 'A set of commands to manage branches.'
arg_name ''
command :branch do |c|

  c.desc 'Create a branch'
  c.arg_name '<branch name>'
  c.command [:new, :create] do |create|
    create.desc          'Specifies the commit/label that will be used as the branch head'
    create.arg_name      'head'
    create.default_value 'head'
    create.flag          [:b, :head]

    create.action do |global_options, options, args|
      branch_name = args.first
      branch_head = options[:head]

      raise 'No branch name specified' if branch_name.nil?

      repository = global_options[:repository]

      raise 'There is already a label with this name' if repository[branch_name]

      repository.set_label branch_name, repository[branch_head, :commit].id
    end
  end

  c.desc 'Delete a branch'
  c.arg_name '<branch name>'
  c.command [:delete, :remove] do |remove|
    remove.action do |global_options, options, args|
      branch_name = args.first

      raise 'No branch name specified' if branch_name.nil?

      repository = global_options[:repository]
      branch     = repository[branch_name]

      raise 'The specified branch does not exits'      if branch.nil?
      raise 'The specified name is not a branch/label' if branch.object_type != :label

      repository.delete_label branch_name
    end
  end

  c.desc 'Switch head to another branch. Does not change any files'
  c.arg_name '<branch name>'
  c.command :switch do |switch|
    switch.action do |global_options, options, args|
      branch_name = args.first

      raise 'No branch name specified' if branch_name.nil?

      repository = global_options[:repository]
      branch     = repository[branch_name]

      raise 'This is the current branch already' if repository.head == branch_name
      raise 'There is no branch with this name'  if branch.nil? or branch.object_type != :label

      changes = repository.commit_status repository['head',      :commit],
                                         repository[branch_name, :commit]

      status  = repository.status repository['head', :commit],
                                  ignore: [/^\.|\/\./]

      # Check for conflicts
      branch_changes      = changes[:created] | changes[:changed] | changes[:deleted]
      working_dir_changes = status[:created]  | status[:changed]  | status[:deleted]
      conflicts           = branch_changes & working_dir_changes

      unless conflicts.empty?
        raise 'Branch switch aborted due to conflics. Please commit or reset local changes'
      end

      repository.set_label :head, branch_name

      # Reset unchanged files to their state in the new branch
      commit = repository['head', :commit]
      tree   = repository[commit.tree]

      tree.all_files(repository.object_store, ignore: working_dir_changes).each do |file, _|
        repository.restore file, commit
      end
    end
  end

end