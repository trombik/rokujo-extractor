# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::JSONL do
  let(:extractor) { described_class.new("/foo.jsonl", model: model, widget_enable: false) }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end
  let(:json_string) { JSON.generate({ text: text }).to_s }

  before do
    allow(extractor).to receive(:file_content).and_return(json_string)
  end

  describe "#extract_sentences" do
    it "returns correct number of lines" do
      expect(extractor.extract_sentences.count).to eq text.split("\n").count
    end

    it "returns the given texts" do
      extracted_sentences = extractor.extract_sentences.map { |s| s[:content] }

      expect(extracted_sentences).to eq text.split("\n")
    end
  end
end
