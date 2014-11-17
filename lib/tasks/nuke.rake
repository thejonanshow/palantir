task :nuke => "cloud:destroy_all" do
  Image.destroy_all
  Event.destroy_all
end
