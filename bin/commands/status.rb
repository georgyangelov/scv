desc 'Shows the created, modified and deleted files'
arg_name '[<commit>]'
command :status do |c|
  c.action do |global_options, options, args|
    repository = global_options[:repository]


    if args.empty?
      commit_id = repository.branch_head
      commit    = commit_id ? repository[commit_id] : nil
      status    = repository.status commit,
                                    ignore: [/^\.|\/\./]
      commit_status = false
    else
      source_commit_id   = repository[args[0], :commit].parents[0]
      source_commit      = source_commit_id ? repository[source_commit_id] : nil
      destination_commit = repository[:head, :commit]

      status = repository.commit_status source_commit,
                                        destination_commit,
                                        ignore: [/^\.|\/\./]
      commit_status = true
    end

    unless commit_status
      if repository.head.nil?
        puts "# No commits"
      else
        puts "# On branch #{repository.head}"
        puts "# On commit #{commit.id.yellow}" if commit
      end

      if repository.config['merge'] and repository.config['merge']['parents']
        parents = repository.config['merge']['parents']

        puts
        puts "# Next commit parents:"

        parents.each do |commit_id|
          puts "#     - #{commit_id.yellow}"
        end
      end

      puts
    end

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