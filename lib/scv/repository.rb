require 'vcs_toolkit/repository'

module SCV
  class Repository < VCSToolkit::Repository
    attr_reader :config

    def initialize(path, init: false)
      repository_path = "#{path}/.scv"

      working_directory = FileStore.new   path
      object_store      = ObjectStore.new FileStore.new(repository_path)
      @config           = Config.new      FileStore.new(repository_path), 'config.yml'

      super object_store,
            working_directory,
            commit_class: Objects::Commit,
            tree_class:   Objects::Tree,
            blob_class:   Objects::Blob,
            label_class:  Objects::Label

      if init
        set_label :master, nil
        set_label :head,   :master

        @config['version'] = SCV::VERSION
        @config.save
      end

      self.head = get_object(:head).reference_id
    end

    ##
    # Resolve references from `object_id` to the first
    # object of type `to_type`.
    # Examples:
    #   label -> commit
    #   label -> label  -> commit
    #   label -> commit -> tree
    #
    # If `object_id` contains '~n' suffix, where `n` >= 0 and
    # the reference path contains a commit, the `parent` pointer
    # of the commit is followed and the `n`-th commit is picked.
    #
    def resolve(object_id, to_type, parent_offset: 0)
      if object_id =~ /^(.+)~([0-9]+)$/
        object_id    = $1
        parent_offset = $2.to_i
      end

      object = self[object_id]

      raise KeyError, "Cannot find object #{object_id}" if object.nil?

      if object.object_type == :commit and parent_offset > 0
        parent_offset.times do
          raise "Commit #{object.id} has more than one parent" if object.parents.size > 1
          raise "Commit #{object_id} has no parents"           if object.parents.size.zero?

          object = self[object.parents.first]
        end
      end

      case object.object_type
      when to_type
        object
      when :label
        resolve object.reference_id, to_type, parent_offset: parent_offset
      when :commit
        resolve object.tree, to_type
      else
        raise "Cannot resolve #{object_id} to a #{to_type}"
      end
    end

    ##
    # Convenience method to resolve objects
    #
    def [](object_id, to_type=nil)
      return super(object_id) if to_type.nil?

      resolve object_id, to_type
    end

    ##
    # Delete a label (only).
    #
    def delete_label(name)
      label = get_object name

      raise 'The object is not a label' if label.object_type != :label

      object_store.remove name
    end

    ##
    # Push history to remote repository
    #
    def push(remote_store, local_branch, remote_branch)
      VCSToolkit::Utils::Sync.sync object_store, local_branch, remote_store, remote_branch
    end

    ##
    # Fetch history from remote repository
    #
    def fetch(remote_store, remote_branch, local_branch)
      VCSToolkit::Utils::Sync.sync remote_store, remote_branch, object_store, local_branch
    end

    ##
    # Create an empty repository in the specified directory.
    #
    # Initializes the directory structure and creates a head label.
    #
    def self.create_at(working_directory)
      directories = %w(.scv/objects .scv/refs .scv/blobs)

      directories.each do |directory|
        FileUtils.mkdir_p File.join(working_directory, directory)
      end

      new working_directory, init: true
    end
  end
end