# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::BulletRemover do
  describe "#call" do
    it "removes bullets at the beginning of a sentence" do
      sentences = [
        "●foo",
        "● foo",
        "- foo",
        "・foo",
        "・foo",
        "1. foo",
        # XXX no reasonable way to remove "1.2" from "1.2 foo"
        "1.2.3 foo",
        "1.2.3.4 foo",
        "✕ foo",
        "◯ foo",
        "※foo",
        "※ foo",
        "*foo",
        "* foo"
      ]
      expect(described_class.new.call(sentences)).to all(match(/\A\s*foo/))
    end

    it "does not remove legitimate beginnings of a sentence" do
      sentences = [
        "-1度",
        "-1.2度",
        "1 kg",
        "1.2 kg",
        "1.2kg",
        "1冊の本",
        "1.5人前",
        "10人前",
        "10 人前"
      ]
      expect(described_class.new.call(sentences)).to eq sentences
    end
  end
end
