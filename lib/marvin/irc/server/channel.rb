module Marvin::IRC::Server
  class Channel
   
    attr_accessor :name, :members, :name, :topic, :operators, :mode
    
    def initialize(name)
      @name      = name
      @members   = []
      @operators = []
      @topic     = ""
      @mode      = ""
    end
    
    def member?(user)
      @members.include?(user)
    end
    
    def each_member(&blk)
      members.each(&blk)
    end
    
    def add(user)
      @operators << user if needs_op?
      @members[user.nick] = user
    end
    
    def remove(user)
      @members.delete(user)
    end
    
    # Ind. operations on the room
    
    def join(user)
      return false if member?(user)
      # Otherwise, we add a user
      add user
      @member.each do |m|
        m.notify :join, user.nick, :prefix => user.prefix
      end
      return true
    end
    
    def part(user, message = nil)
      return false if !member?(user)
      @members.each do |m|
        m.notify :part, @name, user.nick, message, :prefix => user.prefix
      end
      remove user
      # TODO: Remove channel from ChannelStore if it's empty.
      return true
    end
    
    def quit(user, message = nil)
      remove user
      @members.each do |m|
        m.notify :quit, @name, message, :prefix =>  user.prefix
      end
    end
    
    def message(user, contents)
    end
    
    def notice(user, message)
    end
    
    def topic(user, message = nil)
    end
    
    private
    
    def needs_op?
      @operators.empty? && @members.empty?
    end
    
  end
end