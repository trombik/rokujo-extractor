# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Text do
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end
  let(:obj) { described_class.new("/foo.txt") }

  before do
    allow(File).to receive(:read).and_return text
  end

  describe "#new" do
    it "does not raise" do
      expect { obj }.not_to raise_error
    end
  end

  describe "#extract_sentences" do
    it "extracts text in the file" do
      extracted_sentences = obj.extract_sentences.map { |element| element[:content] }
      expect(extracted_sentences).to eq text.split("\n")
    end

    it "extracts correct number of sentences" do
      expect(obj.extract_sentences.count).to eq text.split("\n").count
    end
  end
end
