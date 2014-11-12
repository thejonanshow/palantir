module ImageHelpers
  def phash(char)
    char * (Palantir::HAMMING_DISTANCE_THRESHOLD + 1)
  end
end
