# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Items::ArticleItem do
  let(:item) do
    item = described_class.new("/foo.txt")
    item.acquired_time = Time.now.iso8601
    item.author = "Me"
    item.body = "foo"
    item.description = "desc"
    item.kind = "article"
    item.modified_time = Time.now.iso8601
    item.published_time = Time.now.iso8601
    item.site_name = "Example site"
    item.sources = []
    item.title = "title"
    item.url = "http://example.org/"
    item
  end

  describe "#location" do
    it "returns Pathname instance" do
      expect(item.location.class).to be Pathname
    end

    it "returns path" do
      expect(item.location.to_s).to eq "/foo.txt"
    end
  end

  describe "#opts" do
    it "is a reader accessor" do
      expect(item.opts).to eq({})
    end
  end

  describe "#body" do
    it "is a reader accessor" do
      expect(item.body).to eq "foo"
    end

    it "is a writer accessor" do
      item.body = "bar"
      expect(item.body).to eq "bar"
    end
  end

  describe "#character_count" do
    it "returns character length without space" do
      item.body = "foo\u3000bar\n"
      expect(item.character_count).to eq 6
    end
  end

  describe "#lang" do
    it "auto-detects the language in the body" do
      item.body = "こんにちは"
      expect(item.lang).to eq "ja"
    end
  end

  describe "#item_type" do
    it "returns the last part of the class name" do
      expect(item.item_type).to eq "ArticleItem"
    end
  end

  describe "#to_h" do
    it "serialize the instance in hash" do
      expect(item.to_h).to be_a Hash
    end
  end
end
