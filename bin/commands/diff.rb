desc 'Displays the file changes in the working directory'
arg_name ''
command :diff do |c|
  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]
    status     = repository.status repository.head,
                                   ignore: [/^\.|\/\./]

    status[:changed].each do |file_path|
      changeset = repository.file_difference file_path, repository.head

      added_count   = changeset.count { |change| change.adding?   }
      changed_count = changeset.count { |change| change.changed?  }
      deleted_count = changeset.count { |change| change.deleting? }

      puts
      puts '###'
      puts "# #{file_path}"
      puts '#'
      puts "# #{added_count} #{added_count == 1 ? 'line' : 'lines'} added"       unless added_count.zero?
      puts "# #{changed_count} #{changed_count == 1 ? 'line' : 'lines'} changed" unless changed_count.zero?
      puts "# #{deleted_count} #{deleted_count == 1 ? 'line' : 'lines'} deleted" unless deleted_count.zero?
      puts '###'
      puts changeset.to_s
    end
  end
end