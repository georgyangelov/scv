require 'json'

module SCV
  module Migrations

    class MultipleParents < Migration
      def initialize
        super '0.1.0'
      end

      def apply(working_dir, object_store)
        working_dir.all_files('.scv/objects').each do |file|
          file_path = ".scv/objects/#{file}"
          object = JSON.parse working_dir.fetch(file_path)

          if object['object_type'] == 'commit' and object.key? 'parent'
            object['parents'] = object['parent'].nil? [] : [object['parent']]
            object.delete('parent')

            working_dir.store file_path, JSON.generate(object)
          end
        end
      end
    end

  end
end