# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Metadata::Docx do
  let(:metadata) { described_class.new("/foo.docx") }

  describe "#new" do
    it "does not raise" do
      expect { metadata }.not_to raise_error
    end
  end

  describe "#property_at" do
    let(:node) { instance_double(Nokogiri::XML::Node) }

    before do
      xml_doc = instance_double(Nokogiri::XML::Document)
      allow(xml_doc).to receive(:at_css).and_return(node)
      allow(metadata).to receive(:core_xml_doc).and_return(xml_doc)
    end

    context "when the tag's value contains spaces" do
      it "strips spaces" do
        allow(node).to receive(:text).and_return(" bar ")

        expect(metadata.property_at("foo")).to eq "bar"
      end
    end

    context "when the tag could not be found" do
      it "returns an empty string" do
        allow(node).to receive(:text).and_return(nil)

        expect(metadata.property_at("foo")).to be_empty
      end
    end
  end

  describe "#title" do
    it "returns `title`" do
      allow(metadata).to receive(:property_at).and_return("title")
      expect(metadata.title).to eq "title"
    end
  end

  describe "#file_basename" do
    it "returns base name of location" do
      expect(metadata.file_basename).to eq "foo"
    end
  end

  describe "#uri" do
    it "returns URI" do
      path = instance_double(Pathname)
      allow(path).to receive(:realpath).and_return("/foo.docx")
      allow(metadata).to receive(:location).and_return(path)

      expect(metadata.uri).to eq "file:///foo.docx"
    end
  end
end
