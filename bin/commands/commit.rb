desc 'Commits the current state of the working directory.'
arg_name ''
command :commit do |c|
  c.desc          'The commit message'
  c.arg_name      'message'
  c.flag          [:m, :message]

  c.desc          'The commit author name and email.'
  c.arg_name      'author'
  c.flag          :author

  c.desc          'Use this to override the timestamp of the commit.'
  c.arg_name      'date'
  c.default_value DateTime.now
  c.flag          :date

  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]
    repository_path  = "#{global_options[:dir]}/.scv"
    status = repository.status repository[:head].reference_id, ignore: [/^\.|\/\./]

    if status.none? { |_, files| files.any? }
      raise 'No changes since last commit'
    end

    unless options[:author]
      raise 'Please provide an author with --author="..." or set it globally with `scv config -g author ...`'
    end

    if options[:message]
      commit_message = options[:message].strip
    else
      commit_message_file = "#{repository_path}/COMMIT_MESSAGE"

      system "$EDITOR #{commit_message_file}"
      File.open(commit_message_file, 'r') do |file|
        commit_message = file.read.strip
      end
      FileUtils.rm commit_message_file
    end

    if commit_message.empty?
      raise 'The commit message cannot be empty'
    end

    date = options[:date].is_a?(String) ? DateTime.parse(options[:date]) : options[:date]

    repository.commit commit_message,
                      options[:author],
                      date,
                      ignore: [/^\.|\/\./]
  end
end