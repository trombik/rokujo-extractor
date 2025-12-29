# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::JapaneseSelector do
  describe "#call" do
    it "selects a fully Japanese sentence" do
      sentences = %w[これは日本語だ]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a fully Japanese sentence that ends with 句読点" do
      sentences = %w[これは日本語だ。]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with Kanji" do
      sentences = %w[日本語]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with Katakana" do
      sentences = %w[データ]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with 長音符" do
      sentences = %w[データー]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with 波ダッシュ" do
      sentences = %w[データ〜]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with a period" do
      sentences = %w[一部の日本人はピリオドを句読点に使う.]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "selects a sentence that ends with a exclamation or question mark" do
      sentences = %w[お！ お! お？ お?]
      expect(described_class.new.call(sentences)).to eq sentences
    end

    it "does not select a sentence that ends with non-japanese" do
      sentences = %w[これは日本語だが英語で終わるがenglish]
      expect(described_class.new.call(sentences)).not_to include sentences.first
    end
  end
end
