# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Filters::LineReconstructor do
  let(:input_string) do
    <<~TEXT
      これはテストの一行目の
      続きです。
      タイトル
      これは一行になった二行目です。
      これは最後の三行目で、
      二行に分かれています。
    TEXT
  end
  let(:filter) { described_class.new }

  describe "#call" do
    it "returns String" do
      expect(filter.call(input_string)).to be_a String
    end

    it "reconstructs sentences that spans to multiple lines" do
      expect(filter.call(input_string).split("\n")).to eq [
        "これはテストの一行目の続きです。",
        "タイトル",
        "これは一行になった二行目です。",
        "これは最後の三行目で、二行に分かれています。"
      ]
    end
  end
end
