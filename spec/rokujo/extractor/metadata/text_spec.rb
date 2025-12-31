# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Metadata::Text do
  let(:metadata) { described_class.new(path) }
  let(:path) { Pathname.new "/bar/foo.txt" }
  let(:stat) { instance_double(File::Stat) }
  let(:now) { Time.now.utc.iso8601 }

  before do
    allow(File).to receive(:read).and_return("some contents")
    location = instance_double(Pathname)
    allow(location).to receive_messages(realpath: path.to_s, basename: "foo")
    allow(metadata).to receive(:location).and_return(location)
  end

  describe "#new" do
    it "does not raise" do
      expect { metadata }.not_to raise_error
    end
  end

  describe "#title" do
    it "returns file name without extention" do
      expect(metadata.title).to eq "foo"
    end
  end

  describe "#author" do
    it "returns nil" do
      expect(metadata.author).to be_nil
    end
  end

  describe "#uri" do
    it "returns a file URI" do
      expect(metadata.uri).to eq "file://#{path}"
    end
  end

  describe "#created_at" do
    context "when OS_TYPE is :bsd" do
      it "returns birthtime" do
        stub_const("#{Rokujo::Extractor::Concerns::SystemSpecific}::OS_TYPE", :bsd)
        allow(metadata).to receive(:birthtime).and_return(now)

        expect(metadata.created_at).to eq now
      end
    end

    context "when OS_TYPE is :linux" do
      it "returns birthtime" do
        stub_const("#{Rokujo::Extractor::Concerns::SystemSpecific}::OS_TYPE", :linux)
        allow(metadata).to receive(:birthtime).and_return(now)

        expect(metadata.created_at).to eq now
      end
    end

    context "when OS_TYPE is :macos" do
      it "returns birthtime" do
        stub_const("#{Rokujo::Extractor::Concerns::SystemSpecific}::OS_TYPE", :macos)
        allow(metadata).to receive(:birthtime).and_return(now)

        expect(metadata.created_at).to eq now
      end
    end

    context "when OS_TYPE is :windows" do
      it "returns ctime" do
        stub_const("#{Rokujo::Extractor::Concerns::SystemSpecific}::OS_TYPE", :windows)
        allow(stat).to receive(:ctime).and_return now
        allow(File).to receive(:stat).and_return(stat)

        expect(metadata.created_at).to eq now
      end
    end
  end

  describe "#updated_at" do
    it "returns mtime" do
      allow(stat).to receive(:mtime).and_return now
      allow(File).to receive(:stat).and_return(stat)

      expect(metadata.updated_at).to eq now
    end
  end

  describe "#to_h" do
    it "returns metadata as a Hash" do
      pending "Not implemented yet"
      expect(metadata.to_h).to be_a Hash
    end
  end
end
