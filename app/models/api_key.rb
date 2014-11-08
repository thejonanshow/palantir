class ApiKey < ActiveRecord::Base
  before_create :generate_token

  def generate_token
    return if self.token

    auth_token = SecureRandom.hex
    while !ApiKey.where(token: auth_token).empty?
      auth_token = SecureRandom.hex
    end

    self.token = auth_token
  end
end
