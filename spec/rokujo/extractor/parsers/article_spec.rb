# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Parsers::Article do
  let(:article_string) do
    <<~JSON
      {
        "acquired_time": "2026-02-01T16:14:29.279987+00:00",
        "body":
          "<main>
            ヘディングには句読点がないことが多い
            <div>
              <div>
                <h1>ヘディング1</h1>
                <ul>
                  <li>
                    リストアイテム1
                  </li>
                </ul>
                <table>
                  <row>
                    <cell>無視される</cell>
                  </row>
                </table>
                <p>この文は本文の最初の文である。</p>
                <p>この文は本文の二番目の文である。</p>
                <p>複数の文章が含まれる。この文は本文の最後のの文である。</p>
              </div>
            </div>
          </main>",
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
  let(:parser) do
    described_class.new(article_string, model: model, widget_enable: false)
  end

  describe "#new" do
    it "builds an instance from JSON string" do
      expect(parser).to be_a described_class
    end
  end

  describe "#raw_text" do
    it "returns string" do
      expect(parser.raw_text).to be_a String
    end

    it "starts with the heading" do
      expect(parser.raw_text).to match(/\Aヘディングには句読点がないことが多い/)
    end

    it "adds a period to the heading" do
      expect(parser.raw_text.lines(chomp: true).first).to eq("ヘディングには句読点がないことが多い。")
    end

    specify "each line ends with newline except the last one" do
      expect(parser.raw_text.lines[0..-2]).to all(end_with("\n"))
    end

    specify "each line is stripped" do
      expect(parser.raw_text.lines(chomp: true)).to all(match(/\A\S.*\S\z/))
    end

    it "selects nexted headings" do
      expect(parser.raw_text.lines(chomp: true)).to include("ヘディング1。")
    end

    it "selects lists" do
      expect(parser.raw_text.lines(chomp: true)).to include("リストアイテム1。")
    end

    it "rejects children of table" do
      expect(parser.raw_text.lines).not_to include(match(/無視される/))
      parser.extract_sentences
    end
  end
end
