# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::ShortSentenceRejector do
  describe "#call" do
    it "rejects short sentences" do
      sentences = %w[短い文章]
      expect(described_class.new.call(sentences)).not_to eq sentences
    end

    it "does not reject longer sentences" do
      sentences = %w[常用漢字表にある漢字を主に使用する。]
      expect(described_class.new.call(sentences)).to eq sentences
    end
  end
end
