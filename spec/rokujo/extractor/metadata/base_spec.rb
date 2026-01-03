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

  describe "#type" do
    it "extracts type name from class name" do
      stub_classes = %w[
        What::Ever::Metadata::Text
        What::Ever::Metadata::Docx::GoogleDrive
      ]
      stabbed_instances = stub_classes.map do |classname|
        # create a stubbed subclass of described_class, and create an instance
        stub_const(classname, Class.new(described_class)).new("/foo")
      end

      expect(stabbed_instances.map(&:type)).to match_array(%w[Text Docx::GoogleDrive])
    end
  end

  describe "CORE_ATTRIBUTES_ABSTRACTED" do
    # rubocop:disable RSpec/ExampleLength
    specify "all the methods in it raise not_implemented_error" do
      failed_to_raise_not_implemented_error = Class.new(StandardError).new

      expect do
        ABSTARCT_ATTRIBUTES.each do |attr|
          metadata.send(attr)
          raise failed_to_raise_not_implemented_error
        rescue not_implemented_error
          # ignore because NotImplementedError is expected
        end
      end.not_to raise_error(failed_to_raise_not_implemented_error)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#to_json" do
    it "returns String" do
      allow(metadata).to receive(:to_h).and_return({ foo: "bar" })
      expect(metadata.to_json).to be_a String
    end
  end

  describe "#to_h" do
    it "raises Rokujo::Extractor::Errors::NotImplementedError" do
      expect { metadata.to_h }.to raise_error not_implemented_error
    end
  end
end
