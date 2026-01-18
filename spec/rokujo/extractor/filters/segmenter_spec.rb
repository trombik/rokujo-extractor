# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Filters::Segmenter do
  let(:filter) { described_class.new }
  let(:text) do
    <<~TEXT
      こんにちは、世界。セグメンターは、文章から文を抜き出します。出力は配列です。
    TEXT
  end

  describe "#call" do
    it "returns an Array of segemnts" do
      expect(filter.call(text)).to eq %w[
        こんにちは、世界。
        セグメンターは、文章から文を抜き出します。
        出力は配列です。
      ]
    end
  end
end
