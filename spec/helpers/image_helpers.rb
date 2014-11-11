module ImageHelpers
  def phash(char)
    char * (Image::HAMMING_DISTANCE_THRESHOLD + 1)
  end
end
