module Marvin
  class Status
    CONTROLLERS = {
      :client             => "IRC Client",
      :server             => "IRC Server",
      :ring_server        => "Ring Server",
      :distributed_client => "Distributed Client",
    }
    
    class << self
      
      def show!
        STDOUT.puts ""
        STDOUT.puts " Marvin Status"
        STDOUT.puts " ============="
        STDOUT.puts ""
        if ARGV.include?("--help") || ARGV.include?("-h")
          STDOUT.puts " Usage: script/status [options]\n\n"
          STDOUT.puts " -h, --help    Show this message"
          STDOUT.puts " -f, --full    Include distributed stats"
          STDOUT.puts ""
          exit
        end
        pids = {}
        CONTROLLERS.each_key { |k| pids[k] = Marvin::Daemon.pids_for_type(k) }
        CONTROLLERS.each do |k, v|
          count = pids[k].size
          postfix = count == 1 ? "" : "s"
          STDOUT.puts " #{count} running instance#{postfix} of the #{CONTROLLERS[k]}"
          STDOUT.puts " Pid#{postfix}: #{pids[k].join(", ")}" unless count == 0
          STDOUT.puts ""
        end
        
        if (ARGV.include?("-f") || ARGV.include?("--full")) && !pids[:ring_server].empty?
          require 'rinda/ring'
          DRb.start_service
          STDOUT.puts " Distributed Status"
          STDOUT.puts " ------------------"
          begin
            rs = Rinda::RingFinger.finger.lookup_ring(3)
            STDOUT.puts " Ring Server:        #{rs.__drburi}"
            items = rs.read_all([:marvin_event, Marvin::Settings.distributed_namespace, nil, nil, nil])
            STDOUT.puts " Unprocessed Items:  #{items.size}"
            STDOUT.puts ""
            unless items.empty?
              start_time = items.first[3][:dispatched_at]
              STDOUT.puts  " Earliest Item:     #{start_time ? start_time.strftime("%I:%M%p %d/%m/%y") : "Never"}"
              end_time   = items.last[3][:dispatched_at]
              STDOUT.puts  " Latest Item:       #{end_time ? end_time.strftime("%I:%M%p %d/%m/%y") : "Never"}"
              mapping = {}
              items.each do |i|
                mapping[i[2].inspect] ||= 0
                mapping[i[2].inspect] += 1
              end
              width = mapping.keys.map { |k| k.length }.max
              STDOUT.puts ""
              STDOUT.puts " Unprocessed Message Counts:"
              STDOUT.puts " ---------------------------"
              mapping.each { |k, v| STDOUT.puts " #{k.ljust width}  => #{v}" }
              STDOUT.puts ""
            end
          rescue
            STDOUT.puts " Ring server not found."
            STDOUT.puts ""
          end
        end
        
      end
      
    end
  end
end