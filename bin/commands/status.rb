desc 'Shows the created, modified and deleted files'
arg_name ''
command :status do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]
    commit     = repository.resolve(:head, :commit)
    status     = repository.status commit.id,
                                   ignore: [/^\.|\/\./]

    if repository.head.nil?
      puts "# No commits"
    else
      puts "# On branch #{repository.head}"
      puts "# On commit #{commit.id.yellow}"
    end

    puts

    if status.none? { |_, files| files.any? }
      puts "# No changes"
    end

    if status[:changed].any?
      puts "# Changed:"
      puts status[:changed].map { |file| "+-  #{file}".yellow }
      puts
    end

    if status[:created].any?
      puts "# New:"
      puts status[:created].map { |file| "+   #{file}".green }
      puts
    end

    if status[:deleted].any?
      puts "# Deleted:"
      puts status[:deleted].map { |file| "-   #{file}".red }
      puts
    end
  end
end