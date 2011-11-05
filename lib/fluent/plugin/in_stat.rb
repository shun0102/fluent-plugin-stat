module Fluent

  class StatInput < Input
    Plugin.register_input('stat', self)

    PLUGIN_IOSTAT_PATTERN = /^ *(?<disk_kbt>[^ ]*) *(?<disk_tps>[^ ]*) *(?<disk_mbs>[^ ]*) *(?<cpu_us>[^ ]*) *(?<cpu_sy>[^ ]*) *(?<cpu_id>[^ ]*) *(?<load_m1>[^ ]*) *(?<load_m5>[^ ]*) *(?<load_m15>[^ ]*) */
    TextParser.register_template('iostat', PLUGIN_IOSTAT_PATTERN)

    def initialize
      super
      @hostname = `hostname -s`.chomp!
    end

    config_param :tag, :string

    def configure(conf)
      super
      @parser = TextParser.new
      @parser.configure(conf)
    end

    def start
      super

      result = open("| iostat -w 1")
      while !result.eof
        line = result.gets
        stats = parse_line(line.chomp)[1]
        record = {
          'hostname' => @hostname,
          'stats' => stats
        }

        unless stats["disk_kbt"] == "disk0" || stats["disk_kbt"] == "KB/t"
          Engine.emit(@tag,  Engine.now, record)
        end
      end
    end

    def parse_line(line)
      return @parser.parse(line)
    end

  end

end
