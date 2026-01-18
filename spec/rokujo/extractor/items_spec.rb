# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Items do
  describe Rokujo::Extractor::Items::MetadataItem do
    describe "#new" do
      context "with content as a hash" do
        it "does not raise" do
          expect do
            described_class.new(
              type: :foo,
              content: { uuid: "UUID", date: "today" }
            )
          end.not_to raise_error
        end
      end

      context "with content as nested hash" do
        it "does not raise" do
          expect do
            described_class.new(
              type: :foo,
              content: { foo: { bar: "buz" } }
            )
          end.not_to raise_error
        end

        it "returns nested attrubute" do
          metadata = described_class.new(type: :foo, content: { nested: { key: "value" } })
          expect(metadata.content.dig(:nested, :key)).to eq "value"
        end
      end
    end
  end

  describe Rokujo::Extractor::Items::LineItem do
    describe "#new" do
      it "does not raise" do
        expect do
          described_class.new(text: "a line of text", number: 1)
        end.not_to raise_error
      end

      specify ":number can be either nil (optional) or an Integer" do
        expect do
          described_class.new(text: "foo")
          described_class.new(text: "foo", number: 1)
        end.not_to raise_error
      end

      specify ":number must be an Integer" do
        expect do
          described_class.new(text: "foo", number: "bar")
        end.to raise_error ArgumentError
      end

      specify ":number must be positive" do
        expect do
          described_class.new(text: "foo", number: -1)
        end.to raise_error ArgumentError
      end

      specify ":text must not include newline" do
        expect do
          described_class.new(text: "foo\nbar")
        end.to raise_error ArgumentError
      end
    end
  end

  describe Rokujo::Extractor::Items::SentenceItem do
    describe "#new" do
      context "with MetadataItem or a dic" do
        it "does not raise" do
          expect do
            described_class.new(
              text: "a line of text",
              metadata: Rokujo::Extractor::Items::MetadataItem.new(
                type: :foo,
                content: { uuid: "UUID", date: "today" }
              )
            )
          end.not_to raise_error
        end
      end

      context "with a dict" do
        it "does not raise" do
          expect do
            described_class.new(
              text: "a line of text",
              metadata: {
                type: :foo,
                content: { uuid: "UUID", date: "today" }
              }
            )
          end.not_to raise_error
        end
      end

      context "when the dict does not have madatory keys for MetadataItem" do
        it "raises ArgumentError" do
          expect do
            described_class.new(
              text: "a line of text",
              metadata: { type: "foo" } # :content is missing.
            )
          end.to raise_error ArgumentError
        end
      end

      context "when the keys of the dict are not symbols" do
        it "does not raise error" do
          expect do
            described_class.new(
              text: "a line of text",
              metadata: { "type" => "foo", "content" => "bar" }
            )
          end.not_to raise_error
        end
      end
    end
  end
end
