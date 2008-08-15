require 'uri'
require 'open-uri'
require 'hpricot_scrub'

class QueryMe
  
  def initialize(query)
    url = "http://www.powerset.com/explore/go/" + URI.escape(query.split(" ").join("-"))
    contents = open(url).read
    @info = Hpricot(contents).search("#blurb")
  end
  
  def to_result_string
    if @info && !(result = @info.innerHTML.scrub.strip.split(".").first).blank?
      return result
    else
      return "Ruh-roh! I couldn't find anything. Maybe someone here knows?"
    end
  end
  
end

class KnowledgeHandler < Marvin::Base

  on_event :incoming_message do
    logger.debug "Got Message: #{options.message}"
    #|what|where|when|how
    if options.message.strip =~ /^#{client.nickname}: (who) (.*)$/i
      logger.debug "Matched"
      query("#{$1} #{$2}")
    end
  end
  
  def query(query)
    logger.debug "Processing Query: #{query.inspect}"
    reply QueryMe.new(query).to_result_string
    halt!
  end
  
end