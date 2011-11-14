module Fluent

class Stat

  def initialize
    @prev = Hash.new
    @prev[:cpu] = self.get_proc_info
    @prev[:disk] = self.get_disk_info
    @prev[:net] = self.get_net_info
  end
  
  def get_proc_info
    hash = Hash.new
    IO.readlines('/proc/stat').each do |line|
      info = line.split
      if info.first =~ /^cpu/
        hash[info.first.to_sym] = {
          :user    => info[1].to_i,
          :nice    => info[2].to_i,
          :system  => info[3].to_i,
          :idle    => info[4].to_i,
          :iowait  => info[5].to_i,
          :irq     => info[6].to_i,
          :softirq => info[7].to_i,
          :steal => info[8].to_i,
          :guest => info[9].to_i
        }
      end
    end
    return hash
  end
  
  def get_net_info
    hash = Hash.new
    IO.readlines('/proc/net/dev').each do |line|
      k, v = line.split(":")
      next if v.nil?
      k.strip!
      info = v.split
      if k =~ /[\t]*^eth/
        hash[k.to_sym] = {
          :rbytes => info[0].to_i,
          :rpackets => info[1].to_i,
          :rerrs => info[2].to_i,
          :rdrop => info[3].to_i,
          :rfifo => info[4].to_i,
          :rframe => info[5].to_i,
          :rcompressed => info[6].to_i,
          :rmulticast => info[7].to_i,
          :tbytes => info[8].to_i,
          :tpackets => info[9].to_i,
          :terrs => info[10].to_i,
          :tdrop => info[11].to_i,
          :tfifo => info[12].to_i,
          :tcolls => info[13].to_i,
          :tcarrier => info[14].to_i,
          :tcompressed => info[15].to_i
        }
      end
    end
    return hash
  end

  def get_disk_info
    hash = Hash.new
    IO.readlines('/proc/diskstats').each do |line|
      info = line.split
      unless info[2] =~ /^ram/
        hash[info[2].to_sym] = {
          :rio => info[3].to_i,
          :rmerge => info[4].to_i,
          :rsect => info[5].to_i,
          :ruse => info[6].to_i,
          :wio => info[7].to_i,
          :wmerge => info[8].to_i,
          :wsect => info[9].to_i,
          :wuse => info[10].to_i,
          :running => info[11].to_i,
          :use => info[12].to_i,
          :aveq => info[13].to_i
        }
      end
    end
    return hash
  end

  def get_mem_info
    hash = Hash.new
    IO.readlines('/proc/meminfo').each do |line|
      info = line.split
      info[0].gsub!(/:/, "")
      hash[info[0].to_sym] = info[1].to_i
    end
    return hash
  end

  def calc_cpu_difference(interval = 1.0)
    current = self.get_proc_info
    
    diff = @prev[:cpu].merge(current){ |key, self_val, other_val|
      if key =~ /^cpu/i
        self_val.merge(other_val){ |val_key, val_self_val, val_other_val|
          (val_other_val - val_self_val) / interval
        }
      elsif Numeric === self_val 
        (other_val - self_val) / interval
      end
    }
    @prev[:cpu] = current
    return diff
  end

  def calc_net_difference(interval = 1.0)
    current = self.get_net_info

    diff = @prev[:net].merge(current){ |k, self_hash, other_hash|
      self_hash.merge(other_hash){ |key, self_val, other_val|
        (other_val - self_val) / interval
      }
    }
    @prev[:net] = current
    return diff
  end

  def calc_disk_difference(interval = 1.0)
    current = self.get_disk_info

    diff = @prev[:disk].merge(current){ |k, self_hash, other_hash|
      self_hash.merge(other_hash){ |key, self_val, other_val|
        (other_val - self_val) / interval
      }
    }
    @prev[:disk] = current
    return diff
  end

  def calc_difference(interval = 1.0)
    sleep interval
    stat = Hash.new
    stat[:cpu] = self.calc_cpu_difference
    stat[:net] = self.calc_net_difference
    stat[:disk] = self.calc_disk_difference
    stat[:mem] = self.get_mem_info

    return stat
  end

end
end

