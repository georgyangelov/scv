module SCV::Formatters
  module MergeReport
    def self.print(merge_status)
      puts format(merge_status)
    end

    def self.format(merge_status)
      output = ""

      if merge_status[:merged].any?
        output << "# Automatic merges:\n"

        merge_status[:merged].each do |file|
          output << "    #{file}\n".yellow
        end

        output << "\n"
      end

      if merge_status[:conflicted].any?
        output << "# Conflicted files:\n"

        merge_status[:conflicted].each do |file|
          output << "    #{file}\n".red
        end

        output << "\n"
      end
    end
  end
end