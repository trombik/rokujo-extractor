# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Items::FileItem do
  let(:item) do
    path = instance_double(Pathname)
    allow(path).to receive_messages(realpath: "/foo.txt", basename: "foo.txt")
    item = described_class.new("/foo.txt")
    item.location = path
    item.source = {}
    item.body = [{ text: "こんにちは" }]
    item
  end

  describe "#filename" do
    it "returns basname of the file" do
      expect(item.filename).to eq "foo.txt"
    end
  end

  describe "#url" do
    it "returns file:// URL" do
      expect(item.url.to_s).to start_with("file:///foo.txt")
    end
  end

  describe "#to_h" do
    specify "the hash has filename, uuid and source" do
      expect(item.to_h.keys).to include(:filename, :source, :uuid)
    end
  end
end
