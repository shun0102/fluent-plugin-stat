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

    def configure(conf)
      super
    end

    def start
      super
      stat = Stat.new
      interval = 1

      while true
        result = stat.calc_difference(interval)
        record = {
          'hostname' => @hostname,
          'stats' => result
        }

        Engine.emit(@tag,  Engine.now, record)
      end
    end

  end

end
