# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::UrlRemover do
  describe "#call" do
    let(:sentences) do
      %w[
        http://example.org/
        https://example.org/
        ftp://example.org/
        ftps://example.org/
        file:///tmp
      ]
    end

    it "removes URLs from sentences" do
      expect(described_class.new.call(sentences)).to all(eq "")
    end

    it "removes URLs with leading and trailing Japanese words from sentences" do
      leading_japanse = sentences.map { |s| "日本語#{s}日本語" }

      expect(described_class.new.call(leading_japanse)).to all(eq "日本語日本語")
    end
  end
end
