# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Items::PdfItem do
  let(:now) { Time.now.utc.iso8601 }
  let(:info) do
    {
      AcquiredTime: now,
      Author: "Me",
      ModDate: "D:20240806181506+09'00",
      CreationDate: "D:20240802115228+09'00",
      Title: "title",
      FileURL: "http://example.org/foo.pdf",
      OriginalFilename: "original.pdf",
      SourceSiteName: "source site name",
      SourceURL: "http://example.org/foo/index.html",
      SourceDescription: "source description",
      SourceTitle: "source title"
    }
  end
  let(:doc) do
    doc = instance_double(PDF::Reader)
    allow(doc).to receive_messages(info: info)
    doc
  end
  let(:item) do
    path = instance_double(Pathname)
    allow(path).to receive_messages(realpath: "/foo-hash.pdf", basename: "foo-hash.pdf")
    item = described_class.new("/foo-hash.pdf")
    item.location = path
    item.body = [{ text: "こんにちは" }]
    item.instance_variable_set(:@doc, doc)
    item
  end

  describe "#acquired_time" do
    it "returns AcquiredTime" do
      expect(item.acquired_time).to eq now
    end
  end

  describe "#author" do
    it "returns Author" do
      expect(item.author).to eq "Me"
    end
  end

  describe "#description" do
    it "returns SourceDescription" do
      expect(item.description).to eq "source description"
    end
  end

  describe "#kind" do
    it "returns document" do
      expect(item.kind).to eq "document"
    end
  end

  describe "#modified_time" do
    it "returns ModDate" do
      expect(item.modified_time).to eq "2024-08-06T09:15:06Z"
    end
  end

  describe "#published_time" do
    it "returns CreationDate" do
      expect(item.published_time).to eq "2024-08-02T02:52:28Z"
    end
  end

  describe "#site_name" do
    it "returns SourceSiteName" do
      expect(item.site_name).to eq "source site name"
    end
  end

  describe "#title" do
    it "returns Title" do
      expect(item.title).to eq "title"
    end
  end

  describe "#url" do
    it "returns FileURL" do
      expect(item.url).to eq "http://example.org/foo.pdf"
    end
  end

  describe "#filename" do
    it "returns OriginalFilename" do
      expect(item.filename).to eq "original.pdf"
    end
  end

  describe "#source" do
    it "returns hash of source information" do
      source = {
        title: "source title",
        url: "http://example.org/foo/index.html",
        site_name: "source site name",
        description: "source description"
      }
      expect(item.source).to eq source
    end
  end

  describe "#lang" do
    it "returns guessed language" do
      expect(item.lang).to eq "ja"
    end
  end
end
