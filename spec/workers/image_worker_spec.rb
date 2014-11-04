describe ImageWorker do
  it "calls download on the downloader to get images from s3" do
    worker = ImageWorker.new
    expect(worker.downloader).to receive(:download)
    worker.perform
  end
end
