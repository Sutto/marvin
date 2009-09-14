class KeikiThwopper < Marvin::Base
  
  FROM_REGEXP  = /^(sutto)/i
  THWOP_REGEXP = /(t+h+w+o+m*p+|stab|kill)/i
  
  MESSAGES = [
    "mwahahahaha",
    "you totally deserved it",
    "oi! leave 'em alone!",
    "say hello to my little friend",
    "you know, they could have liked that?"
  ]
  
  on_event :incoming_action,  :thwop_back
  
  def thwop_back
    return if !from || from !~ FROM_REGEXP || options.message !~ THWOP_REGEXP
    action "#{$1}s #{from} (#{MESSAGES[rand(MESSAGES.length)]})"
  end
  
end