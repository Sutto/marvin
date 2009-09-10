# Ragel Parser comes from the Arrbot Guys - Kudos to Halogrium and Epitron.

%%{
  machine irc;
  
  action prefix_servername_start {
    server = Prefixes::Server.new
  }
  
  action prefix_servername {
    server.name << fc
  }
  
  action prefix_servername_finish {
    command.prefix = server
  }
  
  action prefix_hostmask_start {
    hostmask =  Prefixes::HostMask.new
  }
  
  action hostmask_nickname {
    hostmask.nick << fc
  }
  
  action hostmask_user {
    hostmask.user << fc
  }
  
  action hostmask_host {
    hostmask.host << fc
  }
  
  action prefix_hostmask_finish {
    command.prefix = hostmask
  }
  
  action message_code_start {
    code = ""
  }
  
  action message_code {
    code << fc
  }
  
  action message_code_finish {
    command.code = code
  }
  
  action params_start {
    params_1 = []
    params_2 = []
  }
  
  action params {
  }
  
  action params_1_start {
    params_1 << ""
  }
  
  action params_2_start {
    params_2 << ""
  }
  
  action params_1 {
    params_1.last << fc
  }

  action params_2 {
    params_2.last << fc
  }
  
  action params_1_finish {
    command.params = params_1
  }
  
  action params_2_finish {
    command.params = params_2
  }
  
  SPACE          = " ";
  special        = "[" | "\\" | "]" | "^" | "_" | "`" | "{" | "|" | "}" | "+";
  nospcrlfcl     = extend - ( 0 | SPACE | '\r' | '\n' | ':' );
  crlf           = "\r\n";
  shortname      = ( alnum ( alnum | "-" )* alnum* ) | "*";
  multihostname  = shortname ( ( "." | "/" ) shortname )*;
  singlehostname = shortname ( "." | "/" );
  hostname       = multihostname | singlehostname;
  servername     = hostname;
  nickname       = ( alpha | special ) ( alnum | special | "-" ){,15};
  user           = (extend - ( 0 | "\n" | "\r" | SPACE | "@" ))+;
  ip4addr        = digit{1,3} "." digit{1,3} "." digit{1,3} "." digit{1,3};
  ip6addr        = ( xdigit+ ( ":" xdigit+ ){7} ) | ( "0:0:0:0:0:" ( "0" | "FFFF"i ) ":" ip4addr );
  hostaddr       = ip4addr | ip6addr;
  host           = hostname | hostaddr;
  hostmask       = nickname $ hostmask_nickname ( ( "!" user $ hostmask_user )? "@" host $ hostmask_host )?;
  prefix         = ( servername $ prefix_servername > prefix_servername_start % prefix_servername_finish ) | ( hostmask > prefix_hostmask_start % prefix_hostmask_finish );
  code           = alpha+ | digit{3};
  middle         = nospcrlfcl ( ":" | nospcrlfcl )*;
  trailing       = ( ":" | " " | nospcrlfcl )*;
  params_1       = ( SPACE middle $ params_1 > params_1_start ){,14} ( SPACE ":"  trailing $ params_1 > params_1_start )?;
  params_2       = ( SPACE middle $ params_2 > params_2_start ){14}  ( SPACE ":"? trailing $ params_2 > params_2_start )?;
  params         =  ( params_1 % params_1_finish | params_2 % params_2_finish ) $ params > params_start;
  message        = ( ":" prefix SPACE )? ( code $ message_code > message_code_start % message_code_finish ) params? crlf;
  
  main := message;
  
}%%

module Marvin
  module Parsers
    class RagelParser < Marvin::AbstractParser
      
      %% write data;
      
      private
      
      def self.parse!(line)
        data = "#{line.strip}\r\n"

        p = 0;
        pe = data.length
        cs = 0

        hostmask = nil
        server   = nil
        code     = nil
        command  = Command.new(data)

        %% write init;
        %% write exec;

        if cs >= irc_first_final
          command
        else
          raise UnparseableMessage, "Failed to parse the message: #{input.inspect}"
        end
      end
      
    end
  end
end
