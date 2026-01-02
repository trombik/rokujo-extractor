# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Errors do
  describe Rokujo::Extractor::Errors::Base do
    it "accepts message and raises an exception" do
      expect { raise described_class, "message" }.to raise_error described_class
    end
  end

  describe Rokujo::Extractor::Errors::NotImplementedError do
    it "raises a custom NotImplementedError" do
      expect { raise described_class, "message" }.to raise_error described_class
    end
  end
end
