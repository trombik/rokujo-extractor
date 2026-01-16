# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Parsers::JSONL do
  let(:extractor) { described_class.new("/foo.jsonl", model: model, widget_enable: false) }

  before do
    # as `#file_content` returns Enumerator, create an array, which can become
    # Enumerator.
    enum = [
      '{"text":"本文を、敬体（ですます調）あるいは常体（である調）のどちらかに統一する。"}',
      '{"text":"常用漢字表にある漢字を主に使用する。"}'
    ].to_enum
    metadata = instance_double(Rokujo::Extractor::Metadata::JSONL)

    allow(extractor).to receive_messages(
      # retrun enum, which responds to `#with_index` called in
      # `#extracted_sentences`.
      file_content: enum,
      extract_metadata: metadata
    )
    allow(metadata).to receive(:uuid).and_return("file_uuid")
  end

  describe "#extract_sentences" do
    it "returns correct number of lines" do
      expect(extractor.extract_sentences.count).to eq 2
    end

    context "when uuid option is not specified" do
      let(:extractor) do
        described_class.new("/foo.json", model: model, widget_enable: false)
      end

      specify "each element has the file's UUID (default)" do
        uuids = extractor.extract_sentences.map { |e| e[:meta][:uuid] }
        expect(uuids).to all(eq "file_uuid")
      end
    end

    context "when uuid option is `:file`" do
      let(:extractor) do
        described_class.new("/foo.json", model: model, widget_enable: false, uuid: :file)
      end

      specify "each element has the file's UUID" do
        uuids = extractor.extract_sentences.map { |e| e[:meta][:uuid] }
        expect(uuids).to all(eq "file_uuid")
      end
    end

    context "when uuid option is `:record`" do
      let(:extractor) do
        described_class.new("/foo.json", model: model, widget_enable: false, uuid: :record)
      end

      specify "each element has a uniq UUID" do
        uuids = extractor.extract_sentences.map { |e| e[:meta][:uuid] }
        uniq_uuids = uuids.uniq
        expect(uuids).to match_array uniq_uuids
      end

      specify "no element has the file's UUID" do
        uuids = extractor.extract_sentences.map { |e| e[:meta][:uuid] }
        expect(uuids).not_to include("file_uuid")
      end
    end
  end
end
