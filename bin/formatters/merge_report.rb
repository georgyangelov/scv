module SCV::Formatters
  module MergeReport
    def self.print(merge_status)
      if merge_status[:merged].any?
        puts "# Automatic merges:"

        merge_status[:merged].each do |file|
          puts "    #{file}".yellow
        end

        puts
      end

      if merge_status[:conflicted].any?
        puts "# Conflicted files:"

        merge_status[:conflicted].each do |file|
          puts "    #{file}".red
        end

        puts
      end
    end
  end
end