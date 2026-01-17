# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Metadata::ArticleItem do
  let(:metadata) { described_class.new(article.to_json) }
  let(:extra_attributes) { metadata.extra_attributes }
  let(:article) do
    {
      "acquired_time" => "2026-01-15T14:00:01.001236+00:00",
      "body" => "<main>明治維新<p><hi rend=\"#b\">明治維新</hi>（めいじいしん）とは、19世紀...</main>",
      "url" => "https://ja.wikipedia.org/wiki/%E6%98%8E%E6%B2%BB%E7%B6%AD%E6%96%B0",
      "lang" => "ja",
      "author" => "ウィキメディアプロジェクトへの貢献者",
      "description" => nil,
      "kind" => "website",
      "modified_time" => "2025-12-17T13:44:49+00:00",
      "published_time" => "2003-03-19T05:45:20+00:00",
      "site_name" => "ウィキメディア財団",
      "title" => "明治維新 - Wikipedia",
      "item_type" => "ArticleItem",
      "character_count" => 65_502
    }
  end

  describe "#new" do
    it "does not raise an exception" do
      expect { metadata }.not_to raise_error
    end
  end

  describe "#title" do
    it "matches the json property" do
      expect(metadata.title).to eq article["title"]
    end
  end

  describe "#author" do
    it "matches the json property" do
      expect(metadata.author).to eq article["author"]
    end
  end

  describe "#uri" do
    it "matches the json property" do
      expect(metadata.uri).to eq article["url"]
    end
  end

  describe "#created_at" do
    it "matches the json property" do
      expect(metadata.created_at).to eq article["published_time"]
    end
  end

  describe "#updated_at" do
    it "matches the json property" do
      expect(metadata.updated_at).to eq article["modified_time"]
    end
  end

  describe "#acquired_time" do
    it "matches the json property" do
      expect(metadata.acquired_at).to eq article["acquired_time"]
    end
  end

  describe "#extra_attributes" do
    describe "description" do
      it "matches the json property" do
        expect(extra_attributes[:description]).to eq article["description"]
      end
    end

    describe "site_name" do
      it "matches the json property" do
        expect(extra_attributes[:site_name]).to eq article["site_name"]
      end
    end

    describe "kind" do
      it "matches the json property" do
        expect(extra_attributes[:kind]).to eq article["kind"]
      end
    end
  end
end
