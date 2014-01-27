require 'vcs_toolkit/repository'
require 'scv/migrations'

module SCV
  class Repository < VCSToolkit::Repository
    alias_method :working_dir, :staging_area

    def initialize(path, init: false)
      repository_path = "#{path}/.scv"

      working_directory = FileStore.new   path
      object_store      = ObjectStore.new FileStore.new(repository_path)

      unless init
        repository_version   = working_directory.fetch '.scv/config/version'
        available_migrations = Migrations.constants.map do |migration_class|
          Migrations.const_get(migration_class).new
        end

        Repository.migrate working_directory,
                           object_store,
                           migrations:         available_migrations,
                           repository_version: repository_version
      end

      working_directory.store '.scv/config/version', SCV::VERSION

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
    def resolve(object_id, to_type)
      parent_index = 0

      if object_id =~ /^(.+)~([0-9]+)$/
        object_id    = $1
        parent_index = $2.to_i
      end

      object = self[object_id]

      raise KeyError, "Cannot find object #{object_id}" if object.nil?

      case object.object_type
      when to_type
        object
      when :label
        resolve object.reference_id, to_type
      when :commit
        if parent_index > 0
          parent_index.times { object = self[object.parent] }
          resolve object.id, to_type
        else
          resolve object.tree, to_type
        end
      else
        raise "Cannot resolve #{object_id} to a #{to_type}"
      end
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

    ##
    # Attempts to run the neccessary migrations and update the
    # repository version.
    #
    # Yields the applied migration objects.
    #
    def self.migrate(working_directory,
                     object_store,
                     migrations:,
                     repository_version:,
                     last_version: SCV::VERSION)
      current_version = repository_version.split('.').map(&:to_i)
      last_version    = last_version      .split('.').map(&:to_i)

      return [] if (current_version <=> last_version) >= 0

      migrations = migrations.sort_by(&:version)

      migrations.each do |migration|
        if migration.should_apply_to? repository_version
          migration.apply working_directory, object_store
          yield migration if block_given?
        end
      end
    end
  end
end