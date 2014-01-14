desc 'Initialize an empty repository.'
command :init do |c|

  c.action do |global_options, options, args|
    path = global_options[:dir]

    if File.directory? File.join(path, '.scv')
      raise "There is already an SCV repository #{path == '.' ? 'here' : 'at ' + path}"
    end

    SCV::Repository.create_at path

    puts "Job's finished!"
    puts "You can now use `scv commit` to create your first commit!"
  end

end