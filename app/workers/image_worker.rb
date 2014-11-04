class ImageWorker
  include Sidekiq::Worker

  attr_reader :downloader

  def initialize
    @downloader = Downloader.new
  end

  def perform
    new_images = downloader.download
    open_event = Event.where(closed: false).first
    # download new images from the s3 bucket
    #
    # if there is an event in progress move the image to the event folder
    # - if there are 100 or more images in the bucket close the event
    # else if a new image has changed significantly create a new event
    # - create bucket for event
    # - start image counter
    # - upload images to new bucket
    # end
    #
    # put the images in the local cache
    # delete the oldest images until there are 10 in the local cache
    # also delete those images on s3
  end
end
