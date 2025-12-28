# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Base do
  let(:extractor) { described_class.new("/foo") }
  let(:text) do
    <<~TEXT
        1行目の文章です。
      こんにちは、世界!
    TEXT
  end

  describe "#new" do
    it "does not raise" do
      expect { described_class.new("/foo.txt", {}) }.not_to raise_error
    end
  end

  describe "#extract_sentences" do
    before do
      allow(extractor).to receive(:raw_text).and_return(text)
    end

    it "returns Array" do
      expect(extractor.extract_sentences).to be_an Array
    end

    it "returns the same number of elements as input" do
      expect(extractor.extract_sentences.count).to eq text.split("\n").count
    end

    specify "element has Hash" do
      expect(extractor.extract_sentences).to all(be_a Hash)
    end

    specify "element has :content" do
      expect(extractor.extract_sentences.first.keys).to include :content
    end

    specify ":content has text" do
      expect(extractor.extract_sentences.first[:content]).to eq "1行目の文章です。"
    end

    it "combines multiple lines into a single line" do
      input = <<~TEXT
        テストの
        1行目の
        続きです。
        これは2行目で、1行に収まっています。
      TEXT
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).to include("テストの1行目の続きです。", "これは2行目で、1行に収まっています。")
    end

    it "removes lines that does not end with a Japanese character" do
      non_japanese_text = "Redefining merit to justify discrimination.Psychological Science, 16(6), 474-480."
      allow(extractor).to receive(:raw_text).and_return(non_japanese_text)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).not_to include non_japanese_text
    end

    it "does not remove lines that ends with `.`" do
      input = "ジェンダーステレオタイプ活性におよぼす影響がある."
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).to include input
    end
  end
end
