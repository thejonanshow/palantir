require 'open-uri'

module ImageServiceHelpers
  def online?
    begin
      true if open("http://www.google.com/")
    rescue
      false
    end
  end
end
