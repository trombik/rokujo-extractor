# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::StringCleaner do
  let(:instance) { described_class.new }

  describe "#call" do
    it "removes Zero Width Sapces" do
      zws = ["\u200B", "\u200C", "\u200D", "\uFEFF", "\u00A0"]
      expect(instance.call(zws)).to all eq ""
    end

    it "removes Zero Width Spaces and BOM" do
      input = ["Hello\u200BWorld\uFEFF"]
      expect(instance.call(input)).to eq ["HelloWorld"]
    end

    it "replaces Non-breaking Spaces (U+00A0) with a space" do
      input = ["All\u00A0Nippon"]
      expect(instance.call(input)).to eq ["All Nippon"]
    end

    it "does not break &nbsp;" do
      input = ["All Nippon NewsNetwork(ANN)"]
      expect(instance.call(input)).to eq ["All Nippon NewsNetwork(ANN)"]
    end
  end
end
