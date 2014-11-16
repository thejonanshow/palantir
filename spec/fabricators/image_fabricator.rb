Fabricator(:image) do
  url { Faker::Avatar.image(Faker::Lorem.words(2).join('-'), '50x50', 'jpg').split('?').first }
  phash { '1' * (Palantir::HAMMING_DISTANCE_THRESHOLD + 1) }
  deleted { false }
  name { |attrs| attrs[:url].split('/').last }
  directory_name { 'palantir-test-directory-name' }
  hamming_distance { rand(Palantir::HAMMING_DISTANCE_THRESHOLD) }
end
