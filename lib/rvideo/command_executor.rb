require 'open4'


module Process

  def self.descendant_processes(base=Process.pid)
    descendants = Hash.new{|ht,k| ht[k]=[k]}
    Hash[*`ps -eo pid,ppid`.scan(/\d+/).map{|x|x.to_i}].each{|pid,ppid|
      descendants[ppid] << descendants[pid]
    }
    descendants[base].flatten - [base]
  end

end

class IO

  def each_with_timeout(timeout, sep_string=$/)
    q = Queue.new
    th = nil

    timer_set = lambda do |timeout|
      th = new_thread{ to(timeout){ q.pop } }
    end

    timer_cancel = lambda do |timeout|
      th.kill if th rescue nil
    end

    timer_set[timeout]
    begin
      self.each(sep_string) do |buf|
        timer_cancel[timeout]
        yield buf
        timer_set[timeout]
      end
    ensure
      timer_cancel[timeout]
    end
  end

  private

  def new_thread *a, &b
    cur = Thread.current
    Thread.new(*a) do |*a|
      begin
        b[*a]
      rescue Exception => e
        cur.raise e
      end
    end
  end

  def to timeout = nil
    Timeout.timeout(timeout){ yield }
  end

end


module RVideo
  module CommandExecutor
    class ProcessHungError < StandardError; end

    STDOUT_TIMEOUT = 200

    def self.execute_with_block(command, line_separator=$/)
      begin
        pid, stdin, stout, stderr = Open4::open4(command)
        stderr.each_with_timeout(STDOUT_TIMEOUT, line_separator) do |line|
          yield line
        end
      rescue Timeout::Error => e
        raise ProcessHungError
      ensure
        Process.kill("SIGKILL", pid)
      end

    end

  end
end
