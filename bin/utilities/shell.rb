module Shell
  ##
  # Detect if a command exists and can be executed using
  # the OS shell.
  #
  # Based on http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby/5471032#5471032
  #
  def self.command_exist?(name)
    extensions = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

    ENV['PATH'].split(File::PATH_SEPARATOR).find do |path|
      extensions.find { |ext| File.executable? File.join(path, "#{name}#{ext}") }
    end
  end
end