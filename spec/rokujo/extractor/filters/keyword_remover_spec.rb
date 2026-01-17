# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::KeywordRemover do
  let(:instance) { described_class.new }

  describe "#call" do
    it "removes keywords that match KEYWORDS_RE" do
      inputs = %w[
        [画像を見る]
        [画像をみる]
        [全画像をみる]
        [画像]
        [動画]
        [1分動画でわかる]
      ]
      expect(instance.call(inputs)).to all(eq "")
    end
  end
end
