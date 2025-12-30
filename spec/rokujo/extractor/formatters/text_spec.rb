# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Formatters::Text do
  describe "#call" do
    it "returns String of formatted texts only" do
      sentences = %w[foo bar buz]
      expect(described_class.new.call(sentences)).to eq sentences.join("\n")
    end
  end
end
