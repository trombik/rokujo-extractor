# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::PDF do
  let(:extractor) { described_class.new("/foo.pdf", model: model, widget_enable: false) }
  let(:reader) { instance_double(PDF::Reader) }
  let(:pages) { [instance_double(PDF::Reader::Page, text: text)] }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end
  let(:metadata) { instance_double(Rokujo::Extractor::Metadata::Base) }

  before do
    allow(extractor).to receive_messages(reader: reader, extract_metadata: metadata)
    allow(reader).to receive(:pages).and_return(pages)
    allow(metadata).to receive(:uuid).and_return("uuid")
  end

  it "returns correct number of the extracted texts" do
    expect(extractor.extract_sentences.count).to eq 2
  end

  it "runs pdftotext and returns the extracted texts" do
    extracted_sentences = extractor.extract_sentences.map { |s| s[:text] }

    expect(extracted_sentences).to eq text.split("\n")
  end

  it "raises an error with file path in the message" do
    extractor = described_class.new("/foo.pdf")
    allow(extractor).to receive(:`).and_raise StandardError

    expect { extractor.extract_sentences }.to raise_error StandardError, /foo\.pdf/
  end
end
