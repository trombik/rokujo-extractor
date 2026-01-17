# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::StringCleaner do
  let(:instance) { described_class.new }

  describe "#call" do
    it "removes Zero Width Sapces" do
      zws = ["\u200B", "\u200C", "\u200D", "\uFEFF", "\u00A0"]
      expect(instance.call(zws)).to all eq ""
    end

    it "does not break &nbsp;" do
      input = ["All Nippon NewsNetwork(ANN)"]
      expect(instance.call(input)).to eq ["All Nippon NewsNetwork(ANN)"]
    end
  end
end
