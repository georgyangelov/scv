desc 'A set of commands to manage branches.'
arg_name ''
command :branch do |c|

  c.desc 'Create a branch if it does not exist.'
  c.arg_name '<branch name>'
  c.command [:new, :create] do |create|
    create.desc          'Specifies the commit/label that will be used as the branch head'
    create.arg_name      'head'
    create.default_value 'head'
    create.flag          [:b, :head, :base]

    create.action do |global_options, options, args|
      branch_name = args.first
      branch_head = options[:head]

      repository = global_options[:repository]

      raise 'There is already a label with this name' if repository[branch_name]

      repository.set_label branch_name, repository.resolve(branch_head, :commit).id
    end
  end

end