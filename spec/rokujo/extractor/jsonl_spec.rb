# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::JSONL do
  let(:extractor) { described_class.new("/foo.jsonl", model: model, widget_enable: false) }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end

  before do
    # as `#file_content` returns Enumerator, create an array, which can become
    # Enumerator.
    array = text.lines.map { |e| JSON.generate({ text: e }) }

    # retrun enum, which responds to `#with_index` called in
    # `#extracted_sentences`.
    allow(extractor).to receive(:file_content).and_return(array.to_enum)
  end

  describe "#extract_sentences" do
    it "returns correct number of lines" do
      expect(extractor.extract_sentences.count).to eq text.lines.count
    end

    it "returns the given texts" do
      extracted_sentences = extractor.extract_sentences.map { |s| s[:text] }

      expect(extracted_sentences).to eq text.lines(chomp: true)
    end
  end
end
