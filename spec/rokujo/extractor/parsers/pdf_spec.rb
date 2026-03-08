# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Parsers::PDF do
  let(:extractor) do
    obj = described_class.new("/foo.pdf", widget_enable: false)
    obj
  end

  let(:text) do
    <<~TEXT
      常体は、簡潔に、力強い雰囲気で内容を伝えることができる文体です。丁寧ではない印
      象を読み手に与える場合があるため、通常、一般向けのマニュアルの本文では使われませ
      ん。

      3.2 記号


    TEXT
  end

  before do
    reader = instance_double(PDF::Reader)
    allow(reader).to receive_messages(info: {})
    allow(PDF::Reader).to receive(:new).and_return(reader)

    allow(extractor).to receive_messages(
      dump: text
    )
  end

  describe "raw_text" do
    it "removes a short sentence and the following empty line" do
      expect(extractor.raw_text).not_to match(/^3\.2 記号\n\n/)
    end
  end

  describe "#extract_sentences" do
    it "selects マニュアルの本文では使われません as a sentence" do
      sentences = extractor.extract_sentences
      texts = sentences.map { |el| el[:text] }
      expect(texts).to include(match(/マニュアルの本文では使われません。/))
    end

    specify "all sentences have the identical uuid" do
      sentences = extractor.extract_sentences
      uuids = sentences.map { |el| el[:meta][:uuid] }.uniq
      expect(uuids.count).to be 1
    end
  end

  describe "#item" do
    it "has a uuid" do
      item = extractor.item
      allow(item).to receive_messages(url: "/foo.pdf")

      expect(item.uuid).to be_a String
    end

    it "has the same UUID in texts" do
      item = extractor.item
      uuids = extractor.extract_sentences.map { |e| e[:meta][:uuid] }
      allow(item).to receive_messages(url: "/foo.pdf")
      expect(uuids).to all(eq item.uuid)
    end
  end
end
