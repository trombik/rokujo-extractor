# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::VerblessRejector do
  let(:filter) { described_class.new(model: model) }
  let(:sentences) do
    [
      with_verb,
      with_predicate
    ]
  end
  let(:with_verb) { "これは動詞を含む。" }
  let(:with_predicate) { "これは述語です。" }

  describe "#call" do
    it "does not select sentences without verb" do
      # XXX "干場" is labeled with VERB but pos is NOT "動詞" as of 2025/12/30
      without_verb = %w[
        委員：東尚子、高橋聡、土屋麻衣子、西野竜太郎、干場知佳、山本ゆうじ
        名詞、名詞、名詞
      ]
      expect(filter.call(without_verb)).to eq []
    end

    it "selects sentences with verb" do
      expect(filter.call(sentences)).to include(with_verb)
    end

    it "selects sentences with predicate" do
      expect(filter.call(sentences)).to include(with_predicate)
    end
  end
end
