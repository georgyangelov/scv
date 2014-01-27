require 'vcs_toolkit/objects/commit'

module SCV
  module Objects

    class Commit < VCSToolkit::Objects::Commit

      def initialize(date:, **kwargs)
        # Parse the date on deserialization
        date = DateTime.parse date if date.is_a? String

        super
      end

      def hash_objects
        [@message, @tree, parents_for_hash, @author, @date.to_s]
      end

      private

      def parents_for_hash
        if parents.empty?
          nil
        elsif parents.size == 1
          parents.first
        else
          parents
        end
      end

    end

  end
end