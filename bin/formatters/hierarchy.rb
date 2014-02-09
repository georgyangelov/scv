module SCV::Formatters
  module Hierarchy
    def self.print(hash, indent_size: 3, prefix: '')
      hash.each_with_index do |(name, value), index|
        is_last = index == hash.size - 1

        Kernel.print prefix

        unless prefix.empty?
          if is_last
            Kernel.print ' └'
          else
            Kernel.print ' ├'
          end

          Kernel.print '─' * indent_size.pred.pred
          Kernel.print ' '
        end
        Kernel.print name

        if value.is_a? Hash
          if value.size.zero?
            puts ": {}"
          else
            puts

            if prefix.empty?
              inner_prefix = ' ' * indent_size.pred.pred
            else
              inner_prefix = prefix + ' ' + (is_last ? ' ' : '│') + (' ' * indent_size.pred.pred)
            end

            print value, indent_size: indent_size, prefix: inner_prefix
          end
        elsif value.is_a? Array
          puts ": [#{value.join(', ')}]"
        else
          puts ": #{value}"
        end
      end
    end
  end
end