# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Items::DocxItem do
  let(:now) { Time.now.utc.iso8601 }
  let(:core_xml_string) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <cp:coreProperties
          xmlns:cp="http://schemas.openxmlformats.org/officeDocument/2006/characteristics/core-properties"
          xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/"
          xmlns:dcmitype="http://purl.org/dc/dcmitype/"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <dc:title>タイトル</dc:title>
        <dc:subject>サブジェクト</dc:subject>
        <dc:creator>田中 太郎</dc:creator>
        <cp:keywords>Ruby, Word, Metadata</cp:keywords>
        <dc:description>説明</dc:description>
        <cp:lastModifiedBy>佐藤 次郎</cp:lastModifiedBy>
        <cp:revision>2</cp:revision>
        <cp:lastPrinted>2026-01-15T08:00:00Z</cp:lastPrinted>
        <dcterms:created xsi:type="dcterms:W3CDTF">2026-01-01T10:00:00Z</dcterms:created>
        <dcterms:modified xsi:type="dcterms:W3CDTF">2026-02-01T12:00:00Z</dcterms:modified>
      </cp:coreProperties>
    XML
  end
  let(:item) do
    item = described_class.new("/foo.docx")
    item.instance_variable_set(:@core_xml_doc, Nokogiri::XML(core_xml_string).remove_namespaces!)
    item
  end

  describe "#author" do
    it "is creator in coreProperties" do
      expect(item.author).to eq "田中 太郎"
    end
  end

  describe "#description" do
    it "is description in coreProperties" do
      expect(item.description).to eq "説明"
    end
  end

  describe "#kind" do
    it "returns document" do
      expect(item.kind).to eq "document"
    end
  end

  describe "#modified_time" do
    it "is modified in coreProperties" do
      expect(item.modified_time).to eq "2026-02-01T12:00:00Z"
    end
  end

  describe "#published_time" do
    it "is created in coreProperties" do
      expect(item.published_time).to eq "2026-01-01T10:00:00Z"
    end
  end

  describe "#title" do
    it "is title in coreProperties" do
      expect(item.title).to eq "タイトル"
    end
  end

  describe "#site_name" do
    it "is nil" do
      expect(item.site_name).to be_nil
    end
  end

  describe "#source" do
    it "is an empty hash" do
      expect(item.source).to eq({})
    end
  end
end
