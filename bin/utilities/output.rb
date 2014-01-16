module Output
  class Pager
    attr_reader :pager

    def initialize(raw: false)
      if raw or not $stdout.isatty
        @pager = nil
      elsif Shell.command_exist? 'less'
        @pager = 'less -R -F'
      elsif Shell.command_exist? 'more'
        @pager = 'more'
      end
    end

    def print_block
      return yield($stdout) if pager.nil?

      IO.popen(pager, 'w') do |stream|
        begin
          $stdout = stream
          yield stream
        ensure
          $stdout = STDOUT
        end
      end
    end
  end

  def output(raw: false, &block)
    Pager.new(raw: raw).print_block &block
  end

  extend self
end

class Object
  include Output
end