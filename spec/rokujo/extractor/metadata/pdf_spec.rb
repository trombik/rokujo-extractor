# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Metadata::PDF do
  let(:metadata) { described_class.new(path) }
  let(:path) { "/foo.pdf" }

  before do
    reader = instance_double(PDF::Reader)
    allow(PDF::Reader).to receive(:new).and_return reader

    pathname = instance_double(Pathname)
    allow(pathname).to receive(:realpath).and_return(path)
    allow(Pathname).to receive(:new).and_return pathname
  end

  describe "#new" do
    it "does not raise an exception" do
      expect { metadata }.not_to raise_error
    end
  end

  describe "#uri" do
    it "returns URI" do
      expect(metadata.uri.to_s).to eq "file://#{path}"
    end
  end
end
