require 'vcs_toolkit/repository'

module SCV
  class Repository
    def initialize(path)
      object_manager    = ObjectManager.new path
      working_directory = FileManager.new   path

      @vcs_repository = VCSToolkit::Repository.new object_manager,
                                                   working_directory,
                                                   head:         nil,
                                                   commit_class: Objects::Commit,
                                                   tree_class:   Objects::Tree,
                                                   blob_class:   Objects::Blob,
                                                   label_class:  Objects::Label
    end

    ##
    # Create an empty repository in the specified directory.
    #
    # Only initializes the directory structure.
    #
    def self.create_at(working_directory)
      directories = %w(.scv/objects .scv/refs .scv/blobs .scv/config)

      directories.each do |directory|
        FileUtils.mkdir_p File.join(working_directory, directory)
      end
    end
  end
end