module WelcomeHelper
  def local_time(time)
    Time.at(time).in_time_zone("Pacific Time (US & Canada)")
  end
end
