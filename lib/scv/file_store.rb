require 'vcs_toolkit/file_store'

module SCV

  class FileStore < VCSToolkit::FileStore
    def initialize(path)
      raise 'The path is not a directory' unless File.directory? path

      @base_path = path
    end

    def store(path, content)
      path = path_for path

      FileUtils.mkdir_p File.dirname(path)

      # TODO: Decide on the file permissions (maybe in time store them as Git does)
      File.open(path, 'wb') do |file|
        file.write(content)
      end
    end

    def fetch(path)
      raise KeyError unless file? path

      File.open(path_for(path), 'rb') do |file|
        file.read
      end
    end

    def delete_file(path)
      File.unlink path
    end

    def delete_dir(path)
      Dir.unlink path
    end

    def file?(path)
      File.file? path_for(path)
    end

    def directory?(path)
      File.directory? path_for(path)
    end

    def changed?(path, blob)
      fetch(path) != blob.content
    end

    def each_file(path='', &block)
      path = '.' if path.empty?

      Dir.entries(path_for(path)).select do |file_name|
        file? path_for(file_name, path)
      end.each(&block)
    end

    def each_directory(path='', &block)
      path = '.' if path.empty?

      Dir.entries(path_for(path)).select do |name|
        not %w(. ..).include? name and directory? path_for(name, path)
      end.each(&block)
    end

    private

    def path_for(path, base=@base_path)
      if base.empty? or base == '.'
        if path.empty?
          '.'
        else
          path
        end
      else
        File.join(base, path)
      end
    end
  end

end