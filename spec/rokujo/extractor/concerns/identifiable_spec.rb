# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Concerns::Identifiable do
  include described_class

  describe "#uuid" do
    it "generates uuid" do
      expect(uuid).to be_a String
    end
  end

  describe "#hexdigest" do
    it "generates hexdigest" do
      content = "foo bar"
      expect(hexdigest(content)).to be_a String
    end
  end
end
