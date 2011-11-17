module Fluent

  class StatInput < Input
    Plugin.register_input('stat', self)

    def initialize
      super
      @hostname = `hostname -s`.chomp!
      $:.unshift File.dirname(__FILE__)
      require 'stat'
    end

    config_param :tag, :string
    config_param :interval, :time

    def configure(conf)
      super
    end

    def start
      super
      
      @thread = Thread.new(&method(:run))
    end

    def run
      stat = Stat.new
      @running = true
      while @running
        result = stat.calc_difference(@interval)
        record = {
          'hostname' => @hostname,
          'stats' => result
        }
        Engine.emit(@tag,  Engine.now, record)
      end      
    end

    def shutdown
      @running = false
      @thread.join
    end
  end

end
