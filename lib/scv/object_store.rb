require 'vcs_toolkit/exceptions'
require 'scv/objects'

require 'json'

module SCV

  ##
  # Implements VCSToolkit::ObjectStore to store objects on the file system.
  # The directory structure is as follows:
  #
  #   .scv/
  #
  #     objects/
  #       59/
  #         59873e99cef61a60b3826e1cbb9d4b089ae78c2b.json
  #         ...
  #       ...
  #
  #     refs/
  #       HEAD.json
  #       master.json
  #       ...
  #
  #     blobs/
  #       59/
  #         59873e99cef61a60b3826e1cbb9d4b089ae78c2b
  #         ...
  #       ...
  #
  # Each object in `.scv/objects/` is stored in a directory with a name
  # of the first two symbols of the object id.
  # The file extension determines the object format. Possible formats
  # are `json` and `json.gz` (`json.gz` will be supported in the future).
  #
  # For each blob object in `.scv/blobs/` there may be a file in
  # `.scv/objects/`. These blobs follow the same naming scheme as the
  # objects, but they are just binary files (not in `json` format).
  #
  # The refs are named objects (object.named? == true) and can be
  # enumerated.
  #
  class ObjectStore < VCSToolkit::ObjectStore
    def initialize(file_store)
      @store = file_store
    end

    def store(object_id, object)
      if object.named?
        object_path = get_object_path object_id, named: true
      else
        object_path = get_object_path object_id
      end

      if object.is_a? VCSToolkit::Objects::Blob
        @store.store(get_blob_path(object_id), object.content)
      else
        @store.store(object_path, JSON.generate(object.to_hash))
      end
    end

    def fetch(object_id)
      object_location = find_object object_id

      return fetch_blob(object_id) if object_location[:type] == :blob

      hash = JSON.parse(@store.fetch(object_location[:path]))
      object_type = hash['object_type'].capitalize

      raise 'Unknown object type' unless Objects.const_defined? object_type

      Objects.const_get(object_type).from_hash hash
    end

    ##
    # A method not required by VCSToolkit used to remove
    # labels or possibly garbage collection.
    #
    def remove(object_id)
      raise KeyError, 'The object does not exit' unless key? object_id

      location = find_object object_id

      @store.delete_file location[:path]
    end

    def key?(object_id)
      not find_object(object_id).nil?
    end

    def each(&block)
      return [] unless @store.directory? 'refs'

      @store.files('refs').map { |name| name.sub /\..*$/, '' }.each &block
    end

    private

    def fetch_blob(object_id)
      content = @store.fetch get_blob_path(object_id)

      SCV::Objects::Blob.new id: object_id, content: content
    end

    def get_object_path(object_id, named: false)
      if named
        File.join 'refs', "#{object_id}.json"
      else
        File.join 'objects', object_id[0...2], "#{object_id}.json"
      end
    end

    def get_blob_path(object_id)
      File.join 'blobs', object_id.to_s[0...2], object_id.to_s
    end

    def find_object(object_id)
      [
        {path: get_object_path(object_id),              type: :object},
        {path: get_object_path(object_id, named: true), type: :label },
        {path: get_blob_path(object_id),                type: :blob  },
      ].find { |location| @store.file? location[:path] }
    end
  end
end