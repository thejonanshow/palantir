Fabricator(:image) do |image|
  url { Faker::Avatar.image(Faker::Lorem.words(2).join('-'), '50x50', 'jpg').split('?').first }
  phash { '1' * (Image::HAMMING_DISTANCE_THRESHOLD + 1) }
  deleted { false }
  name { |attrs| attrs[:url].split('/').last }
  directory_name { 'palantir-test-directory-name' }
end
