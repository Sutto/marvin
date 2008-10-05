module Marvin
  class Util
    class << self
      
      # Return the channel-name version of a string by
      # appending "#" to the front if it doesn't already
      # start with it.
      def channel_name(name)
        return name.to_s[0..0] == "#" ? name.to_s : "##{name}"
      end
      alias chan channel_name
      
      def arguments(input)
        prefix, *ending = input.split(":")
        prefix = prefix.split(" ")
        prefix << ending.join(":").strip
        return prefix
      end

      # Specifies the last parameter of a response, used to
      # specify parameters which have spaces etc (for example,
      # the actual message part of a response).
      def last_param(section)
        section && ":#{section.to_s.strip} "
      end
      alias lp last_param
     
    end
  end
end