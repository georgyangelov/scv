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
        [@message, @tree, @parent, @author, @date.to_s]
      end

    end

  end
end