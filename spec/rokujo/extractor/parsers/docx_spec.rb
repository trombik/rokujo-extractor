# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Parsers::Docx do
  let(:extractor) { described_class.new("/foo.docx", model: model, widget_enable: false) }
  let(:doc) { instance_double(Docx::Document) }
  let(:paragraphs) do
    text = <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
    paragraph = instance_double(Docx::Elements::Containers::Paragraph, text: text)
    [paragraph, paragraph]
  end
  let(:metadata) { instance_double(Rokujo::Extractor::Metadata::Base) }

  before do
    allow(metadata).to receive(:uuid).and_return("uuid")
    allow(Docx::Document).to receive(:open).and_return doc
  end

  it "correctly returns sentences" do
    allow(doc).to receive(:paragraphs).and_return(paragraphs)

    expect(extractor.extract_sentences.count).to eq 4
  end
end
