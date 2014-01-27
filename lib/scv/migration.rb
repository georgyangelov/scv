module SCV

  class Migration
    attr_reader :version

    def initialize(version)
      @version = version.split('.').map(&:to_i)
    end

    def should_apply_to?(current_version)
      current_version = current_version.split('.').map(&:to_i)

      (version <=> current_version) > 0
    end

    def apply(working_directory, object_store)
      raise NotImplementedError
    end

    def revert(working_directory, object_store)
      raise NotImplementedError
    end
  end

end