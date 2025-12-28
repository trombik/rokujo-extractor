# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Docx do
  let(:extractor) { described_class.new("/foo.docx", model: @model) }
  let(:doc) { instance_double(Docx::Document) }
  let(:paragraph) { instance_double(Docx::Elements::Containers::Paragraph, text: text) }
  let(:paragraphs) { [paragraph, paragraph] }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end

  before(:all) do
    @model = Spacy::Language.new(Rokujo::Extractor::Base::DEFAULT_SPACY_MODEL_NAME)
  end

  it "correctly returns sentences" do
    allow(Docx::Document).to receive(:open).and_return doc
    allow(doc).to receive(:paragraphs).and_return(paragraphs)

    expect(extractor.extract_sentences.count).to eq 4
  end
end
