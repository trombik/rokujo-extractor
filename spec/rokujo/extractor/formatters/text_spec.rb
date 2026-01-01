# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Formatters::Text do
  describe "#call" do
    it "returns String of formatted texts only" do
      sentences = %w[foo bar buz].map { |e| { content: e } }
      results = described_class.new.call(sentences).split("\n")

      expect(results).to match_array(%w[foo bar buz])
    end
  end
end
