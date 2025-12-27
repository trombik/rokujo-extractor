# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Docx do
  let(:extractor) { described_class.new("/foo.docx") }

  let(:doc) { instance_double(Docx::Document) }
  let(:paragraph) { instance_double(Docx::Elements::Containers::Paragraph, text: "我輩は猫である。名前はまだない。") }
  let(:paragraphs) { [paragraph, paragraph] }

  it "correctly returns sentences" do
    allow(Docx::Document).to receive(:open).and_return doc
    allow(doc).to receive(:paragraphs).and_return(paragraphs)

    expect(extractor.extract_sentences.count).to eq 4
  end
end
