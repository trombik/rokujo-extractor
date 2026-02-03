# frozen_string_literal: true

require "nokogiri"

require_relative "base"
require_relative "../items/article_item"

module Rokujo
  module Extractor
    module Parsers
      # Extracts PDF files.
      class Article < Base
        def initialize(string, opts = {})
          @item = Rokujo::Extractor::Items::ArticleItem.from_string(string)
          super("", opts)
        end

        def raw_text
          return @raw_text if @raw_text

          @raw_text = extract_text(doc.at_css("main")).join("\n")
        end

        private

        # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        def extract_text(node, lines = [])
          node.children.each do |child|
            # ignore tables as they don't contain sentences but words
            next if child.name == "table"

            # news articles often have text nodes as (sort of) headings.
            if child.text? || child.name.match?(/^(?:h[1-6]|li|list)$/)
              content = append_punct_to_the_end(child.text)
              lines << content unless content.empty?
            elsif child.name == "p"
              content = strip_nbsp_and_spaces(child.text)
              lines << content unless content.empty?
            else
              extract_text(child, lines)
            end
          end
          lines
        end
        # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity

        def strip_nbsp_and_spaces(str)
          # normalize spaces, including nbsp
          str.gsub(/[[:space:]]+/, " ").strip
        end

        def append_punct_to_the_end(str)
          stripped = strip_nbsp_and_spaces(str)
          return "" if stripped.empty?

          stripped << "。" unless stripped.match(/。、！!？?/)
        end

        def doc
          @doc ||= Nokogiri::XML.fragment(item.body)
        end
      end
    end
  end
end
