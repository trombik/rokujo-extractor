# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::JSONL do
  let(:extractor) { described_class.new("/foo.jsonl", model: model, widget_enable: false) }
  let(:text) do
    <<~TEXT
      本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。
      常用漢字表にある漢字を主に使用する。
    TEXT
  end
  let(:enum) { text.lines.map { |e| JSON.generate({ text: e }) }.to_enum }

  before do
    # as `#file_content` returns Enumerator, create an array, which can become
    # Enumerator.

    # retrun enum, which responds to `#with_index` called in
    # `#extracted_sentences`.
    allow(extractor).to receive(:file_content).and_return(enum)
  end

  describe "#extract_sentences" do
    it "returns correct number of lines" do
      expect(extractor.extract_sentences.count).to eq text.lines.count
    end

    it "returns the given texts" do
      extracted_sentences = extractor.extract_sentences.map { |s| s[:text] }

      expect(extracted_sentences).to eq text.lines(chomp: true)
    end

    context "when per_segment_uuid is true" do
      let(:extractor) do
        described_class.new("/foo.json", model: model, widget_enable: false, per_segment_uuid: true)
      end

      before do
        metadata = instance_double(Rokujo::Extractor::Metadata::JSONL)
        allow(metadata).to receive(:uuid).and_return("metadata_uuid")
        allow(extractor).to receive_messages(
          extract_metadata: metadata,
          file_content: enum
        )
      end

      specify "each element has a uniq UUID" do
        uuids = extractor.extract_sentences.map { |s| s[:meta][:uuid] }
        uniq_uuids = uuids.uniq

        expect(uuids).to match_array uniq_uuids
      end

      specify "no element has metadata_uuid" do
        uuids = extractor.extract_sentences.map { |s| s[:meta][:uuid] }

        expect(uuids).not_to include "metadata_uuid"
      end
    end

    context "when per_segment_uuid is false" do
      let(:extractor) do
        described_class.new("/foo.json", model: model, widget_enable: false, per_segment_uuid: false)
      end

      specify "each element not use the same metadata_uuid" do
        metadata = instance_double(Rokujo::Extractor::Metadata::JSONL)
        allow(metadata).to receive(:uuid).and_return("metadata_uuid")
        allow(extractor).to receive_messages(
          extract_metadata: metadata,
          file_content: enum
        )
        uuids = extractor.extract_sentences.map { |s| s[:meta][:uuid] }

        expect(uuids).to all(eq "metadata_uuid")
      end
    end
  end
end
