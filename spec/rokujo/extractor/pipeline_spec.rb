# frozen_string_literal: true

class Adder
  def call(input, _widget)
    input + 1
  end
end

RSpec.describe Rokujo::Extractor::Pipeline do
  describe "#call" do
    it "processes given steps one by one" do
      pipeline = described_class.new(Adder.new, Adder.new)

      expect(pipeline.run(1)).to eq 3
    end
  end
end
