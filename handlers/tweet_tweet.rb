# Not Yet Complete: Twitter Client in Channel.
class TweetTweet < Marvin::Base
  
  on_event :client_connected do
    start_tweeting
  end
  
  def start_tweeting
    client.periodically 180, :check_tweets
  end
  
  def handle_check_tweets
    logger.debug ">> Check Tweets"
  end
  
  def show_tweet(tweet)
  end
  
end