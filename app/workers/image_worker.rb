class ImageWorker
  include Sidekiq::Worker

  attr_reader :downloader

  def initialize
    @downloader = Downloader.new
  end

  def perform
    images = downloader.download
  end
end
