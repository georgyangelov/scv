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

      repository.set_label branch_name, repository.resolve(branch_head, :commit).id
    end
  end

  c.desc 'Delete a branch (label)'
  c.arg_name '<branch name>'
  c.command [:delete, :remove] do |remove|
    remove.action do |global_options, options, args|
      branch_name = args.first

      raise 'No branch name specified' if branch_name.nil?

      repository = global_options[:repository]
      branch      = repository[branch_name]

      raise 'The specified branch does not exits'      if branch.nil?
      raise 'The specified name is not a branch/label' if branch.object_type != :label

      repository.delete_label branch_name
    end
  end

end