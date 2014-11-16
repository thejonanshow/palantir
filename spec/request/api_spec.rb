require 'rails_helper'

RSpec.describe Palantir::API, :type => :request do
  include Warden::Test::Helpers

  let(:image_service) { ImageService.new }
  let(:image) { Fabricate.build(:image) }

  before(:all) do
    Warden.test_mode!

    Fog.mock!

    @image_service = ImageService.new
    @user = Fabricate(:user)

    create_image_directory
  end

  before(:each) do
    login_as(@user)
    Fog::Mock.reset
  end

  def post_request(image, options = {}, headers = {})
    store_image(image)

    attributes = image.attributes.select do |k, _|
      !['id', 'created_at', 'updated_at'].include? k
    end

    post "/api/images", { :image => attributes }.merge(options), headers
  end

  context "GET /api/hamming_distances", focus: true do
    it "returns 200" do
      get '/api/hamming_distances'
      expect(response).to have_http_status(:ok)
    end

    it "returns all the hamming distances" do
      post_request(image)
      post_request(image)
      get '/api/hamming_distances'
      expect(response.body).to eql([image.hamming_distance,0].to_s)
    end
  end

  context "GET /api/hamming_distances/latest", focus: true do
    it "returns 200" do
      post_request(image)
      allow_any_instance_of(Image).to receive(:set_hamming_distance).and_return(image.hamming_distance)
      post_request(image)
      get '/api/hamming_distances/latest'
      expect(response.body).to eql(image.hamming_distance.to_s)
    end

    it "returns the latest hamming distance" do
    end
  end

  context "GET /api/images/latest" do
    it "returns 200" do
      post_request(image)
      get '/api/images/latest'
      expect(response).to have_http_status(:ok)
    end

    it "returns the latest image url" do
      post_request(image)
      get '/api/images/latest'
      expect(response.body).to eql(image.url)
    end
  end

  context "POST /api/images" do
    it "returns 201" do
      post_request(image)
      expect(response).to have_http_status(:created)
    end

    it "returns 401 if user is logged out" do
      logout
      post_request(image)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 201 if user is logged in" do
      post_request(image)
      expect(response).to have_http_status(:created)
    end

    it "returns 201 if params include existing authentication token" do
      logout
      post_request(image, { :access_token => @user.authentication_token })
      expect(response).to have_http_status(:created)
    end

    it "creates an image" do
      expect do
        post_request(image)
      end.to change {Image.count}.from(0).to(1)
    end

    it "creates an image with the given attributes" do
      post_request(image)

      image.attributes.keys.each do |attribute|
        next if ['id', 'created_at', 'updated_at'].include? attribute
        expect(Image.last.send(attribute)).to eql(image.attributes[attribute])
      end
    end

    it "creates an event if the hamming distance is greater than the threshold" do
      post_request(image)

      allow_any_instance_of(Event).to receive(:copy_image)

      expect do
        post_request(Fabricate(:image, phash: phash('2')))
      end.to change { Event.all.length }.from(0).to(1)
    end

    it "does not create an event if there is an open event" do
      post_request(image)

      image2 = Fabricate.build(:image, phash: phash('2'))

      allow_any_instance_of(Event).to receive(:copy_image)
      post_request(image2)

      expect(Event).to_not receive(:create)
      post_request(image)
    end

    it "copies saved images to the open event" do
      store_image(image)
      event = Event.create(closed: false)

      post_request(image)

      image.directory_name = event.directory_name
      expect(@image_service.image_exists?(image)).to be true
    end

    it "closes the event when the event has copied the maximum number of images" do
      event = Event.create(closed: false)

      99.times do |n|
        event.image_service.upload_image(
          'spec/fixtures/eye_of_sauron.jpg',
          event.directory_name,
          "image#{n}.jpg"
        )
      end

      expect { post_request(image) }.to change { event.reload.closed }.from(false).to(true)
    end

    it "deletes the oldest image" do
      10.times { store_image(Fabricate(:image)) }
      expect { post_request(image) }.to change { Image.where(deleted: true).count }.from(0).to(1)
    end

    it "deletes the oldest image from the remote" do
      post_request(image)
      9.times { store_image(Fabricate(:image)) }

      expect(image_service.image_exists?(image)).to be true
      post_request(Fabricate.build(:image))
      expect(image_service.image_exists?(image)).to be false
    end
  end
end
