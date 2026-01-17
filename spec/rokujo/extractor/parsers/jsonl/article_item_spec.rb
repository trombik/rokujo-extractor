# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Rokujo::Extractor::Parsers::JSONL::ArticleItem do
  let(:extractor) { described_class.new("/foo.jsonl", model: model, widget_enable: false, uuid: :record) }

  before do
    enum = [
      {
        body: "
          <main>
              短い見出し
              最小文字数以上の長い見出しは削除されない。
              最小文字数以上の長い見出しなら、語尾が句読点で終わっていなくても一文として認識される
              特定の文字で終わっていれば、句読点は追加されない!
              特定の文字で終わっていれば、句読点は追加されない！
              特定の文字で終わっていれば、句読点は追加されない?
              特定の文字で終わっていれば、句読点は追加されない？
              <p><hl>この文章</hl>は削除されない。</p>
              <p>本文です。</p>
          </main>
          "
      }.to_json
    ].to_enum
    allow(extractor).to receive_messages(
      # retrun enum, which responds to `#with_index` called in
      # `#extracted_sentences`.
      file_content: enum
    )
  end

  describe "#extract_sentences" do
    let(:texts) { extractor.extract_sentences.map { |e| e[:text] } }

    it "rejects short headings" do
      expect(texts).not_to include("短い見出し")
    end

    it "includeslong longer headings" do
      expect(texts).to include("最小文字数以上の長い見出しは削除されない。")
    end

    it "includes children tags under <main>" do
      expect(texts).to include("この文章は削除されない。")
    end

    specify "children tags under <main> does not include any XML tags" do
      expect(texts).not_to include("<hl>この文章</hl>は削除されない。")
    end

    it "includes long headnings, by appending a period to headings" do
      expect(texts).to include("最小文字数以上の長い見出しなら、語尾が句読点で終わっていなくても一文として認識される。")
    end

    it "does not append a period when the headning ends with specific characters" do
      texts_without_period = texts.select { |t| t.match("特定の文字で終わっていれば、句読点は追加されない") }
      expect(texts_without_period).to all(match(/[^。]\z/))
    end

    it "rejects short sentence in <p> tags" do
      expect(texts).not_to include("本文です。")
    end

    it "tags every sentence with a unique ID" do
      sentences = extractor.extract_sentences
      uuids = sentences.map { |el| el[:meta][:uuid] }.uniq
      expect(uuids.count).to eq 1
    end

    specify "all the UUIDs are in a valid UUIDv7 format" do
      t = /[0-9a-zA-Z]/
      r = t
      sentences = extractor.extract_sentences
      uuids = sentences.map { |el| el[:meta][:uuid] }.uniq
      # 019bcb1b-4e27-7230-8202-67c2b914e482
      expect(uuids).to all(match(/\A#{t}{8}-#{t}{4}-7#{r}{3}-#{r}{4}-#{r}{12}\z/))
    end
  end
end
