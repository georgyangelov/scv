desc 'Displays the commit history'
arg_name ''
command [:history, :log] do |c|
  c.action do |global_options, options, args|
    repository = SCV::Repository.new global_options[:dir]

    output do
      repository.history.each do |commit|
        puts "Commit #{commit.id.yellow}"
        puts "Author #{commit.author.blue}"
        puts "Date   #{commit.date.strftime "%A %Y-%m-%d %H:%M:%S %z".green}"

        puts
        puts commit.message.lines.map { |line| "    #{line}" }.join ''
        puts
      end
    end
  end
end