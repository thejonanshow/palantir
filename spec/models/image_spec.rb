require 'rails_helper'

RSpec.describe Image, :type => :model do
  let(:image_one) { Image.create(url: 'url', phash: '111111111111111') }
  let(:image_two) { Image.create(url: 'url', phash: '222222222222222') }

  context "#hamming_distance" do
    it "returns the hamming distance to the given image" do
      expect(image_two.hamming_distance(image_one)).to be 15
    end
  end

  context "#hamming_distance_exceeds_threshold?" do
    it "returns true if the hamming distance to the most recent image exceeds threshold" do
      $debug = true
      image_one
      expect(image_two.hamming_distance_exceeds_threshold?).to be true
      $debug = false
    end
  end

  it "creates an event if the hamming distance is greater than the threshold" do
    image_one

    expect do
      image_two
    end.to change { Event.count }.from(0).to(1)
  end
end
