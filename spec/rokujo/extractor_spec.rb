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
  end
end
