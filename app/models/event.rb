class Event < ActiveRecord::Base
  after_initialize :set_bucket_name

  def set_bucket_name
    self.bucket_name = "palantir_event_#{Time.now.strftime '%Y-%m-%d_%H-%M-%S-%9L'}"
  end
end
