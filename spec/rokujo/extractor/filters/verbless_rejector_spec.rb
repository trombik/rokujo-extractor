# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::VerblessRejector do
  let(:filter) { described_class.new(model: model) }

  describe "#call" do
    it "does not select sentences without verb" do
      # XXX "干場" is labeled with VERB but pos is NOT "動詞" as of 2025/12/30
      without_verb = %w[
        委員：東尚子、高橋聡、土屋麻衣子、西野竜太郎、干場知佳、山本ゆうじ
        名詞、名詞、名詞
        委員長：田中千鶴香
        ロードと解析
        昨日の干場
      ]
      expect(filter.call(without_verb)).to eq []
    end

    it "selects sentences with verb or predicate" do
      with_predicate = %w[
        白い
        雪は白い
        雪は白いです
        雪は白かった
        これは述語です
        動詞を含む
        自然言語処理を用いたシステム
        明日行きます
        干場が走る
        景色が美しい
        彼は学生だ
        行くの?
        実行について
      ]

      expect(filter.call(with_predicate)).to match_array(with_predicate)
    end
  end
end
