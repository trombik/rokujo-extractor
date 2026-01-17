# frozen_string_literal: true

require "nokogiri"
require "json"

require_relative "../jsonl"

module Rokujo
  module Extractor
    module Parsers
      class JSONL
        # A parser to parse ArticleItem in JSONL files.
        class ArticleItem < Rokujo::Extractor::Parsers::JSONL
          MINIMUM_HEADING_LENGTH = 16

          def initialize(location, opts = {})
            super
          end

          def extract_sentences
            sentences = []
            file_content.with_index(1) do |line, index|
              content = raw_text(line, index)
              results = pipeline.run(content).map.with_index do |sentence, index|
                # XXX unlike JSONL, UUID is always per-record UUID because a
                # record is a complete article.
                sentence_to_h(sentence, index, uuid_v7)
              end
              sentences.concat results
            end
            sentences
          end

          def raw_text(line, index)
            xml_string = JSON.parse(line)["body"]
            doc = Nokogiri::XML.fragment(xml_string)
            process_xml(doc).map(&:strip).join("\n")
          rescue StandardError => e
            raise e, "Failed to parse JSON at:\n" \
                     "#{location.realpath}:#{index}\n" \
                     "#{line.inspect}"
          end

          def process_xml(doc)
            result = doc.at_xpath("./main").children.map do |node|
              # if the node is a TEXT node, additional processing is required.
              # otherwise, just dump the node.text.
              node.text? ? map_text_node_to_nil_or_string(node) : node.text
            end
            result.flatten.compact
          end

          def map_text_node_to_nil_or_string(text_node)
            result = text_node.text.split("\n").map do |text|
              # ignore short headings and sentences.
              if text.length < MINIMUM_HEADING_LENGTH
                nil
              else
                # append a period to headings.
                #
                # headings often lack a period. Without a period, the filters
                # cannot recognize them as a sentence.
                append_period_if_missing_at_the_end(text)
              end
            end
            result.compact
          end

          def append_period_if_missing_at_the_end(text)
            text << "。" unless text[-1] =~ /[。?？!！]/
            text
          end
        end
      end
    end
  end
end
