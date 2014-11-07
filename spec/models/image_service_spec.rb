require 'rails_helper'

RSpec.describe ImageService, :type => :model do
  context ".client" do
    it "only creates one client" do
      expect(ImageService.client).to eql(ImageService.client)
    end
  end
end
