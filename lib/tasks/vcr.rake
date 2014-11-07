task :vcr do
  path = 'spec/fixtures/vcr_cassettes'
  FileUtils.rm_rf(path)
  puts "Deleted #{path}"
end
