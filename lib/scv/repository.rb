require 'forwardable'
require 'vcs_toolkit/repository'

module SCV
  class Repository
    def initialize(path, init: true)
      repository_path = "#{path}/.scv"

      working_directory = FileStore.new   path
      object_store      = ObjectStore.new repository_path

      @vcs_repository = VCSToolkit::Repository.new object_store,
                                                   working_directory,
                                                   commit_class: Objects::Commit,
                                                   tree_class:   Objects::Tree,
                                                   blob_class:   Objects::Blob,
                                                   label_class:  Objects::Label

      create_label :head, nil if init

      self.head = get_object(:head)
    end

    extend Forwardable
    def_delegators :@vcs_repository, :head, :head=

    ##
    # Return the object with this object_id or nil if it doesn't exist.
    #
    def get_object(object_id)
      @vcs_repository.repository.fetch object_id if @vcs_repository.repository.key? object_id
    end

    alias_method :[], :get_object

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

    protected

    ##
    # Creates a label (named object) pointing to `reference_id`
    #
    # If the label already exists it is overriden.
    #
    def create_label(name, reference_id)
      label = Objects::Label.new object_id: name, reference_id: reference_id

      @vcs_repository.repository.store name, label
    end
  end
end