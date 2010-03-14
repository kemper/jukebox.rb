require File.expand_path(File.dirname(__FILE__) + "/../test_helper.rb")

class Time
  class << self

    def now
      @time || original_new
    end

    alias_method :original_new, :new
    alias_method :new, :now

    def is(time = nil)
      raise "A block is required" unless block_given?
      begin
        previous, @time = @time, time || now
        yield
      ensure
        @time = previous
      end
    end
  end
end
