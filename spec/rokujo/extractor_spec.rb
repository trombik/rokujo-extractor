# frozen_string_literal: true

RSpec.describe Rokujo::Extractor do
  it "has a version number" do
    expect(Rokujo::Extractor::VERSION).not_to be_nil
  end

  describe ".create" do
    context "when *.pdf is given" do
      it "returns PDF class" do
        expect(described_class.create("/foo.pdf")).to be_a Rokujo::Extractor::PDF
      end
    end

    context "when *.txt is given" do
      it "returns Text class" do
        expect(described_class.create("/foo.txt")).to be_a Rokujo::Extractor::Text
      end
    end

    context "when *.docx is given" do
      it "returns Text class" do
        expect(described_class.create("/foo.docx")).to be_a Rokujo::Extractor::Docx
      end
    end

    context "when unsupported file is given" do
      it "raise UnsupportedFileTypeError" do
        allow(Marcel::MimeType).to receive(:for).and_return "image/svg+xml"

        expect { described_class.create("/foo.svg") }.to raise_error Rokujo::Extractor::UnsupportedFileTypeError
      end
    end

    context "when supported file is given" do
      it "raise UnsupportedFileTypeError" do
        allow(Marcel::MimeType).to receive(:for).and_return "text/plain"

        expect { described_class.create("/foo") }.not_to raise_error
      end
    end
  end
end
