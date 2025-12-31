# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Metadata::Base do
  let(:metadata) { described_class.new("/foo") }
  let(:not_implemented_error) { Rokujo::Extractor::Errors::NotImplementedError }

  describe "#new" do
    it "does not raise an exception" do
      expect { metadata }.not_to raise_error
    end
  end

  describe "#to_json" do
    it "returns String" do
      allow(metadata).to receive(:to_h).and_return({ foo: "bar" })
      expect(metadata.to_json).to be_a String
    end
  end

  describe "#title" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.title }.to raise_error not_implemented_error
    end
  end

  describe "#author" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.author }.to raise_error not_implemented_error
    end
  end

  describe "#uri" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.uri }.to raise_error not_implemented_error
    end
  end

  describe "#created_at" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.created_at }.to raise_error not_implemented_error
    end
  end

  describe "#updated_at" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.updated_at }.to raise_error not_implemented_error
    end
  end

  describe "#acquired_at" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.acquired_at }.to raise_error not_implemented_error
    end
  end

  describe "#to_h" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.to_h }.to raise_error not_implemented_error
    end
  end
end
