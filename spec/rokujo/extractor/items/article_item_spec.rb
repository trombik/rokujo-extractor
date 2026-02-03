# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Items::ArticleItem do
  let(:sentences) do
    [
      { text: "ヘディングには句読点がないことが多い。",
        meta: { line_number: 1, uuid: "019c20af-c05e-7c4a-aaff-f9d5eccfce83" } },
      { text: "この文は本文の最初の文である。", meta: { line_number: 2, uuid: "019c20af-c05e-7c4a-aaff-f9d5eccfce83" } },
      { text: "この文は本文の二番目の文である。", meta: { line_number: 3, uuid: "019c20af-c05e-7c4a-aaff-f9d5eccfce83" } },
      { text: "複数の文章が含まれる。", meta: { line_number: 4, uuid: "019c20af-c05e-7c4a-aaff-f9d5eccfce83" } },
      { text: "この文は本文の最後のの文である。", meta: { line_number: 5, uuid: "019c20af-c05e-7c4a-aaff-f9d5eccfce83" } }
    ]
  end
  let(:article_string) do
    <<~JSON
      {
        "acquired_time": "2026-02-01T16:14:29.279987+00:00",
        "body": #{sentences.map { |el| el[:text] }.join("\n").to_json},
        "sentences": #{sentences.to_json},
        "url": "https://news.example.org/articles/eecbc2dc77b9a42c4fa236e424eb96d0c1fcd7e1",
        "lang": "ja",
        "author": "なんとかスポーツ",
        "description": "記事の説明",
        "kind": "article",
        "modified_time": "2026-02-02T00:06:00+09:00",
        "published_time": "2026-02-02T00:06:00+09:00",
        "site_name": "なんとかニュース",
        "title": "記事のタイトル",
        "item_type": "ArticleItem",
        "character_count": 42,
        "sources": []
      }
    JSON
  end
  let(:item) do
    described_class.from_string(article_string)
  end

  describe "#location" do
    it "returns Pathname instance" do
      expect(item.location).to eq "https://news.example.org/articles/eecbc2dc77b9a42c4fa236e424eb96d0c1fcd7e1"
    end
  end

  describe "#opts" do
    it "is a reader accessor" do
      expect(item.opts).to eq({})
    end
  end

  describe "#body" do
    it "is an String" do
      expect(item.body).to be_a String
    end

    it "is a writer accessor" do
      item.sentences = [{ text: "bar" }]
      expect(item.sentences.first[:text]).to eq "bar"
    end
  end

  describe "#character_count" do
    it "returns character length without space" do
      item.sentences = [{ text: "foo\u3000" }, { text: "bar\n" }]
      item.instance_variable_set("@character_count", nil)
      expect(item.character_count).to eq 6
    end
  end

  describe "#lang" do
    it "auto-detects the language in the sentences" do
      item.sentences = [{ text: "こんにちは" }]
      item.instance_variable_set("@lang", nil)
      expect(item.lang).to eq "ja"
    end
  end

  describe "#item_type" do
    it "returns the last part of the class name" do
      expect(item.item_type).to eq "ArticleItem"
    end
  end

  describe "#to_h" do
    it "serialize the instance in hash" do
      expect(item.to_h).to be_a Hash
    end
  end

  context "when the item is nested" do
    specify "soueces attribute has ArticleItem" do
      item.sources = [
        { title: "foo" }
      ]

      expect(item.sources.first).to be_a described_class
    end

    specify "to_h correctly expand sources" do
      item.sources = [
        { title: "foo" }
      ]

      expect(item.to_h[:sources].first).to be_a Hash
    end
  end
end
