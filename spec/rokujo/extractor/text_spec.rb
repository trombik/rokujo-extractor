# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Text do
  let(:text) do
    <<~TEXT
      Hello, world!
      A sample text
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
      expect(obj.extract_sentences.first).to include(content: "Hello, world!")
    end

    it "extracts correct number of sentences" do
      expect(obj.extract_sentences.count).to eq text.split("\n").count
    end
  end
end
