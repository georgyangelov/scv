desc 'Shows the created, modified and deleted files'
arg_name ''
command :status do |c|
  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]
    status     = repository.status repository[:head].reference_id,
                                   ignore: [/^\.|\/\./]

    puts "# On commit #{repository.head}"
    puts

    if status.none? { |_, files| files.any? }
      puts "# No changes"
    end

    if status[:changed].any?
      puts "# Changed:"
      puts status[:changed].map { |file| "+-  #{file}" }
      puts
    end

    if status[:created].any?
      puts "# New:"
      puts status[:created].map { |file| "+   #{file}" }
      puts
    end

    if status[:deleted].any?
      puts "# Deleted:"
      puts status[:deleted].map { |file| "-   #{file}" }
      puts
    end
  end
end