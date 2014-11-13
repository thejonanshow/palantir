require 'rails_helper'

RSpec.describe Palantir::API, :type => :request do
  let(:image) { Fabricate.build(:image) }

  before(:all) do
    Fog.mock!

    token = 'secret'
    ApiKey.create(token: token)

    @image_service = ImageService.new
    create_image_directory

    @headers = {
      'Authorization' => "Token token=#{token}"
    }
  end

  before(:each) do
    Fog::Mock.reset
  end

  def post_request(image, headers = @headers)
    store_image(image)

    attributes = image.attributes.select do |k, _|
      !['id', 'created_at', 'updated_at'].include? k
    end

    post "/api/images", { :image => attributes }, headers
  end

  context "GET /api/images/latest" do
    it "returns 200" do
      post_request(image)
      get '/api/images/latest', {}, @headers
      expect(response).to have_http_status(:ok)
    end

    it "returns the latest image url" do
      post_request(image)
      get '/api/images/latest', {}, @headers
      expect(response.body).to eql(image.url)
    end
  end

  context "POST /api/images" do
    it "returns 200" do
      post_request(image)
      expect(response).to have_http_status(:created)
    end

    it "returns 401 if authorization fails" do
      fake_auth_header = { 'Authorization' => "Token token=FAKE" }
      post_request(image, fake_auth_header)
      expect(response).to have_http_status(:unauthorized)
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
  end
end
