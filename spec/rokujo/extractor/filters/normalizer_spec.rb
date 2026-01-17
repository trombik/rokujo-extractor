# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Filters::Normalizer do
  describe "#call" do
    let(:filter) { described_class.new }

    context "with Enclosed Alphanumerics (U+2460-24FF)" do
      it "converts single-digit enclosed numbers to half-width" do
        expect(filter.call("①❶⑴⒈")).to eq "11(1)1."
      end

      it "converts enclosed numbers 10 and above to appropriate 2-digit strings" do
        expect(filter.call("⑩⑳⒇⒛")).to eq "1020(20)20."
      end

      it "converts enclosed alphabets to half-width" do
        expect(filter.call("ⓐⓩ")).to eq "az"
      end
    end

    context "with Bracket unification" do
      it "replaces various Japanese brackets with half-width square brackets" do
        expect(filter.call("【】〔〕《》")).to eq "[][][]"
      end
    end

    context "with Wave dash and tilde issues" do
      it "unifies various wave dashes to the standard Japanese wave dash (U+301C)" do
        expect(filter.call("~～〜")).to eq "〜〜〜"
      end
    end

    context "with Quotes and symbols" do
      it "unifies smart quotes to standard half-width quotes" do
        expect(filter.call("“quote” ‘single’")).to eq "\"quote\" 'single'"
      end
    end

    context "with Basic NFKC functionality" do
      it "converts full-width alphanumerics to half-width" do
        expect(filter.call("ＡＢＣ１２３")).to eq "ABC123"
      end

      it "converts half-width katakana to full-width" do
        expect(filter.call("ｱｲｳｴｵ")).to eq "アイウエオ"
      end
    end

    context "with Complex cases" do
      it "correctly processes strings with mixed decorations" do
        input = "【❶】《最新》〜⑪月のニュース〜"
        expect(filter.call(input)).to eq "[1][最新]〜11月のニュース〜"
      end
    end

    context "with Emojis" do
      it "removes all icons including ⚡ using Extended_Pictographic" do
        input = "News ⚡: Launch 🚀 at 10:00"
        expect(filter.call(input)).to eq "News : Launch  at 10:00"
      end
    end
  end
end
