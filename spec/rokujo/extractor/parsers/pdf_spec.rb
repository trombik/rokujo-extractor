# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Parsers::PDF do
  let(:extractor) { described_class.new("/foo.pdf", model: model, widget_enable: false) }

  let(:text) do
    <<~TEXT
      常体は、簡潔に、力強い雰囲気で内容を伝えることができる文体です。丁寧ではない印
      象を読み手に与える場合があるため、通常、一般向けのマニュアルの本文では使われませ
      ん。

      3.2 記号


    TEXT
  end

  before do
    metadata = instance_double(Rokujo::Extractor::Metadata::PDF)
    allow(metadata).to receive(:uuid).and_return("uuid")
    allow(extractor).to receive_messages(
      dump: text,
      metadata: metadata
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
  end
end
