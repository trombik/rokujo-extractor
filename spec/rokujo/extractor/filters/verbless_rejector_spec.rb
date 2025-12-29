# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::VerblessRejector do
  let(:filter) { described_class.new(model: model) }
  let(:sentences) do
    [
      without_verb,
      with_predicate,
      with_verb
    ]
  end
  let(:without_verb) { "名詞、名詞、名詞" }
  let(:with_verb) { "これは動詞を含む。" }
  let(:with_predicate) { "これは述語です。" }

  describe "#call" do
    it "does not select sentences without verb" do
      expect(filter.call(sentences)).not_to include(without_verb)
    end

    it "selects sentences with verb" do
      expect(filter.call(sentences)).to include(with_verb)
    end

    it "selects sentences with predicate" do
      expect(filter.call(sentences)).to include(with_predicate)
    end
  end
end
