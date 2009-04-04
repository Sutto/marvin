module Marvin
  class Daemon
    class << self
      
      def alive?(pid)
        return Process.getpgid(pid) != -1
      rescue Errno::ESRCH
        return false
      end
      
      def kill_all(type = :all)
        if type == :all
          files = Dir[Marvin::Settings.root / "tmp/pids/*.pid"]
          files.each { |f| kill_all_from f }
        elsif type.is_a?(Symbol)
          kill_all_from(pid_file_for(type))
        end
        return nil
      end
      
      def daemonize!
        exit if fork
        Process.setsid
        exit if fork
        self.write_pid
        File.umask 0000
        STDIN.reopen  "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT
        Marvin::Settings.verbose = false
      end
      
      def cleanup!
        f = pids_file_for(Marvin::Loader.type)
        FileUtils.rm_f(f) if (pids_from(f) - Process.pid).blank?
      end
      
      def pids_for_type(type)
        pids_from(pid_file_for(type))
      end
      
      protected

      def kill_all_from(file)
        pids = pids_from(file)
        pids.each { |p| Process.kill("TERM", p) unless p == Process.pid }
        FileUtils.rm_f(file)
      rescue => e
        STDOUT.puts e.inspect
      end

      def pid_file_for(type)
        Marvin::Settings.root / "tmp" / "pids" / "marvin-#{type.to_s.underscore}.pid"
      end

      def pids_from(file)
        return [] unless File.exist?(file)
        pids = File.read(file)
        pids = pids.split("\n").map { |l| l.strip.to_i(10) }.select { |p| alive?(p) }
      end

      def write_pid
        f = pid_file_for(Marvin::Loader.type)
        pids = pids_from(f)
        pids << Process.pid unless pids.include?(Process.pid)
        File.open(f, "w+") { |f| f.puts pids.join("\n") }
      end
      
    end
  end
end