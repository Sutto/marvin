module Marvin::IRC::Server
  class Channel
    include Marvin::Dispatchable
    
    attr_accessor :name, :members, :name, :topic, :operators, :mode
    
    def initialize(name)
      @name      = name
      @members   = []
      @operators = []
      @topic     = ""
      @mode      = ""
      dispatch :channel_created, :channel => self
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
      @member.each { |m| m.notify :join, user.nick, :prefix => user.prefix }
      dispatch :outgoing_join, :target => @name, :nick => user.nick
      return true
    end
    
    def part(user, message = nil)
      return false if !member?(user)
      @members.each { |m| m.notify :part, @name, user.nick, message, :prefix => user.prefix }
      remove user
      # TODO: Remove channel from ChannelStore if it's empty.
      dispatch :outgoing_part, :target => @name, :user => user, :message => message
      check_emptyness!
      return true
    end
    
    def quit(user, message = nil)
      remove user
      @members.each { |m| m.notify :quit, @name, message, :prefix =>  user.prefix }
      # TODO: Remove channel from the store if it's empty
      dispatch :outgoing_quit, :target => @name, :user => user, :message => message
      check_emptyness!
    end
    
    def message(user, message)
      @members.each { |m| m.notify :privmsg, @name, message, :prefix => user.prefix unless user == m }
      dispatch :outgoing_message, :target => @name, :user => user, :message => message
    end
    
    def notice(user, message)
      @members.each { |m| m.notify :notice, @name, message, :prefix => user.prefix unless user == m }
      dispatch :outgoing_notice, :target => @name, :user => user, :message => message
    end
    
    def topic(user = nil, t = nil)
      return @topic if t.blank?
      @topic = t
      @members.each { |m| m.notify :topic, @name, t, :prefix => user.prefix }
      dispatch :outgoing_topic, :target => @name, :user => user, :topic => t
      return @topic
    end
    
    private
    
    def needs_op?
      @operators.empty? && @members.empty?
    end
    
    def check_emptyness!
      destroy if @members.empty?
    end
    
    def destroy
      Marvin::IRC::Server::ChannelStore.delete(@name)
      dispatch :channel_destroyed, :channel => self
    end
    
  end
end