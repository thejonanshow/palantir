require 'twitter'

class NotificationService
  def self.client
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
      config.access_token        = Rails.application.secrets.twitter_access_token
      config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
    end
  end

  def client
    NotificationService.client
  end

  def notify(message)
    client.update(message)
  end
end
