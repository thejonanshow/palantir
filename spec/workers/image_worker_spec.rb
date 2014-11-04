describe ImageWorker do
  let(:worker) { ImageWorker.new }
  it "downloads the images from the downloader" do
    expect(worker.downloader).to receive(:download)
    worker.perform
  end

  it "finds any open events" do
    expect(Event).to receive(:where).with(closed: false).and_return([])
    worker.perform
  end
end
