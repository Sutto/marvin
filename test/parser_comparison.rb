require 'benchmark'
require File.join(File.dirname(__FILE__),'../lib/marvin')

LINES = [
  ":irc.darth.vpn.spork.in 366 testbot #testing :End of NAMES list",
  ":Helsinki.FI.EU.Undernet.org PONG Helsinki.FI.EU.Undernet.org :Helsinki.FI.EU.Undernet.org",
  ":testnick USER guest tolmoon tolsun :Ronnie Reagan",
  "LIST #twilight_zone,#42",
  ":WiZ LINKS *.bu.edu *.edu",
  ":Angel PRIVMSG Wiz :Hello are you receiving this message ?",
  ":RelayBot!n=MarvinBo@203.161.81.201.static.amnet.net.au JOIN :#relayrelay",
  ":SuttoL!n=SuttoL@li6-47.members.linode.com PRIVMSG #relayrelay :testing...",
  ":wolfe.freenode.net 004 MarvinBot3000 wolfe.freenode.net hyperion-1.0.2b aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStTuUvVwWxXyYzZ01234569*@ bcdefFhiIklmnoPqstv"
]
PARSERS = [Marvin::Parsers::RagelParser, Marvin::Parsers::SimpleParser, Marvin::Parsers::RegexpParser]

LINES.each do |line|
  
  puts "Processing: #{line}"
  puts ""
  cmd = []
  
  PARSERS.each do |p|
    parser = p.new(line)
    ev    = parser.to_event
    puts "Parser:  #{p.name}"
    if ev.nil?
      puts "Unknown Event"
    else
      puts ev.to_hash.inspect
    end
    puts ""
  end
  puts ""
  
end

puts ""
puts ""
puts "==============="
puts "| SPEED TESTS |"
puts "==============="
puts ""

width = PARSERS.map { |p| p.name.length }.max + 2

ITERATIONS = 1000

Benchmark.bm(width) do |b|
  PARSERS.each do |parser|
    b.report("#{parser.name}: ") do
      LINES.each do |l|
        ITERATIONS.times do
          e = parser.new(l).to_event
          unless e.nil?
            e.to_hash # Get a hash
          end
        end
      end
    end
  end
end
