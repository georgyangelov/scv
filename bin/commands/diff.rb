desc 'Displays the file changes in the working directory'
arg_name ''
command :diff do |c|
  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]
    status     = repository.status repository.head,
                                   ignore: [/^\.|\/\./]


    output do
      status[:changed].each do |file_path|
        changeset = repository.file_difference file_path, repository.head

        added_count   = changeset.count { |change| change.adding?   }
        changed_count = changeset.count { |change| change.changed?  }
        deleted_count = changeset.count { |change| change.deleting? }

        diff_lines = changeset.flat_map do |change|
          if change.unchanged?
            [" #{change.new_element}"]
          elsif change.deleting?
            ["-#{change.old_element}".red]
          elsif change.adding?
            ["+#{change.new_element}".green]
          elsif change.changed?
            ["-#{change.old_element}".red, "+#{change.new_element}".green]
          else
            raise "Unknown change in the diff #{change.action}"
          end
        end

        puts
        puts "##".bold
        puts "# #{file_path}".bold
        puts '#'.bold
        puts "# #{added_count} #{added_count == 1 ? 'line' : 'lines'} added".bold       unless added_count.zero?
        puts "# #{changed_count} #{changed_count == 1 ? 'line' : 'lines'} changed".bold unless changed_count.zero?
        puts "# #{deleted_count} #{deleted_count == 1 ? 'line' : 'lines'} deleted".bold unless deleted_count.zero?
        puts "##".bold
        puts diff_lines.join('')
      end
    end
  end
end