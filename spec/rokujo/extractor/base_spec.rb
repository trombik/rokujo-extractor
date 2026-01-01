# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Base do
  let(:extractor) { described_class.new("/foo", model: model, widget_enable: false) }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end
  let(:metadata) { instance_double(Rokujo::Extractor::Metadata::Base) }

  before do
    allow(metadata).to receive(:uuid).and_return("uuid")
    allow(extractor).to receive(:metadata).and_return(metadata)
  end

  describe "#new" do
    it "does not raise" do
      expect { extractor }.not_to raise_error
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
      expect(extractor.extract_sentences.first[:content]).to eq text.split("\n").first
    end

    it "combines multiple lines into a single line" do
      input = <<~TEXT
        これはテストの
        1行目の
        続きです。
        これは2行目で、1行に収まっています。
      TEXT
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).to include("これはテストの1行目の続きです。", "これは2行目で、1行に収まっています。")
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

    it "removes a sentence without VERB" do
      input = "例：カーナビゲーションシステム"
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).not_to include input
    end

    it "removes a sentence that starts with ● and withput VERB" do
      # some characters, such as `●` are labled as VERB depending on model
      # (ja_core_news_sm).
      input = "●  名詞、名詞、名詞、名詞、名詞"
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).not_to include input
    end

    it "does not remove a sentence that starts with ● and with VERB" do
      # some characters, such as `●` are labled as VERB
      input = "●  動詞が含まれていれば削除しないが、記号は取り除かれる"
      allow(extractor).to receive(:raw_text).and_return(input)
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).to include input.tr("● ", "")
    end
  end

  describe "#extract_metadata" do
    it "raises NotImplementedError" do
      expect { extractor.extract_metadata }.to raise_error Rokujo::Extractor::Errors::NotImplementedError
    end
  end
end
