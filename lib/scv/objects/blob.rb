require 'vcs_toolkit/objects/blob'

module SCV
  module Objects

    ##
    # Extends the VCSToolkit::Objects::Blob class to not keep
    # the file contents in memory and only read the file if
    # it needs to.
    #
    # The content passed to the initializer should be either an open IO
    # object or a file path string (that can be opened with File.open).
    #
    class Blob < VCSToolkit::Objects::Blob

      ##
      # Used to check if the content is a reference
      # (File object) or the content itself (String).
      #
      attr_reader :content_in_memory

      ##
      # The content should be an open File object or the content itself (String).
      #
      def initialize(content:, object_id: nil, **context)
        @content_in_memory = content.is_a? String

        super content:          content,
              object_id:        object_id,
              verify_object_id: content_in_memory,
              **context
      end

      def release_resources
        content.close unless content_in_memory
        super
      end

      protected

      ##
      # Overrides generate_id to be able to get the file hash without
      # buffering it in memory.
      #
      def generate_id
        if content_in_memory
          Digest::SHA1.hexdigest content
        else
          sha1 = Digest::SHA1.new

          while buffer = content.read(16 * 1024)
            sha1.update(buffer)
          end
          content.rewind

          sha1.hexdigest
        end
      end
    end

  end
end