require 'vcs_toolkit/repository'

module SCV
  class Repository < VCSToolkit::Repository
    def initialize(path, init: false)
      repository_path = "#{path}/.scv"

      working_directory = FileStore.new   path
      object_store      = ObjectStore.new repository_path

      super object_store,
            working_directory,
            commit_class: Objects::Commit,
            tree_class:   Objects::Tree,
            blob_class:   Objects::Blob,
            label_class:  Objects::Label

      set_label :head, nil if init

      self.head = get_object(:head)
    end

    ##
    # Creates a commit which is a snapshot of the
    # staging area (currently the working directory).
    #
    def commit(message, author, date)
      super
    end

    ##
    # Create an empty repository in the specified directory.
    #
    # Initializes the directory structure and creates a head label.
    #
    def self.create_at(working_directory)
      directories = %w(.scv/objects .scv/refs .scv/blobs .scv/config)

      directories.each do |directory|
        FileUtils.mkdir_p File.join(working_directory, directory)
      end

      new working_directory, init: true
    end
  end
end