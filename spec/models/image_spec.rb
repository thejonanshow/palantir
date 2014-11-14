require 'rails_helper'

RSpec.describe Image, :type => :model do
  let(:image_one) {
    Image.create(
      url: 'url',
      phash: '111111111111111',
      directory_name: 'palantir-test-directory-name'
    )
  }
  let(:image_two) {
    Image.create(
      url: 'url',
      phash: '222222222222222',
      directory_name: 'palantir-test-directory-name'
    )
  }

  before(:all) do
    Fog.mock!
  end

  after(:each) do
    Fog::Mock.reset
  end

  context "#hamming_distance" do
    it "returns the hamming distance to the given image" do
      allow_any_instance_of(Event).to receive(:copy_image)
      expect(image_two.hamming_distance(image_one)).to be 15
    end
  end

  context "#hamming_distance_exceeds_threshold?" do
    it "returns true if the hamming distance to the most recent image exceeds threshold" do
      image_one
      allow_any_instance_of(Event).to receive(:copy_image)
      expect(image_two.hamming_distance_exceeds_threshold?).to be true
    end
  end

  it "creates an event if the hamming distance is greater than the threshold" do
    image_one

    allow_any_instance_of(Event).to receive(:copy_image)
    expect do
      image_two
    end.to change { Event.count }.from(0).to(1)
  end

  it "marks the oldest image as deleted if we've reached maximum images" do
    100.times { Fabricate(:image) }
    expect { Fabricate(:image) }.to change { Image.where(deleted: true).length }.from(0).to(1)
  end
end
