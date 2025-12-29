# frozen_string_literal: true

require "pragmatic_segmenter"
require "ruby-spacy"
require_relative "helpers"

module Rokujo
  module Extractor
    # The base class of Extractors
    class Base
      include Rokujo::Extractor::Helpers

      attr_reader :file_path, :metadata

      MIN_CHAR_LEN_BREAK = 10
      MIN_CHAR_LEN_SELECT = 10
      DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

      def initialize(file_path, **opts)
        @file_path = file_path
        @metadata = opts.fetch(:metadata, {})
        @nlp = opts.fetch(:model) do |key|
          warn "#{key} is not passed. Using #{DEFAULT_SPACY_MODEL_NAME}"
          Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
        end
      end

      def extract_sentences
        content = with_spinner(message: "[:spinner] Parsing ...") { raw_text }
        return [] if content.nil? || content.empty?

        reconstructed_text = reconstruct_lines(content)
        segmented_texts = with_spinner(message: "[:spinner] Segmenting ...") { segment_text reconstructed_text }

        filtered_segments = filter_segments segmented_texts
        filtered_segments.map.with_index do |s, i|
          {
            content: s.strip,
            line_number: i + 1,
            meta_info: @metadata
          }
        end
      end

      protected

      def raw_text
        raise NotImplementedError, "Subclasses must implement raw_text"
      end

      def segment_text(text)
        PragmaticSegmenter::Segmenter.new(text: text, language: "ja").segment
      end

      private

      def filter_segments(segments)
        with_progress(message: "Filtering [:bar]", total: segments.count) do |bar|
          segments.select do |segment|
            # ends with Japanese?
            result = segment.strip.match?(/[\p{hiragana}\p{katakana}\p{han}][\p{P}\p{Pe}]?\z/) &&
                     segment.length >= MIN_CHAR_LEN_SELECT &&
                     # reject if the segment does not include VERB or predicate, likely
                     # a title or an item name
                     segment_include_verb?(segment)
            bar.advance
            result
          end
        end
      end

      def segment_include_verb?(text)
        doc = @nlp.read(text)
        # does the sentence have a verb?
        return true if doc.tokens.any? { |token| token.pos == "VERB" }

        # does the sentence have predicate (述語)?
        return true if tokens_include_predicate?(doc.tokens)

        false
      end

      # True if tokens include predicate. Predicate is not labled as VERB but
      # as NOUN (日本人) + AUX (です) + PUNCT (。)
      def tokens_include_predicate?(tokens)
        # We need to know the last token but not PUNCT, such as `。`.
        tokens_without_punct = tokens.reject { |token| token.pos.match?(/PUNCT|SYM/) }

        # does the sentence have 述語? such as "述語です"?
        last_token = tokens_without_punct.last
        prev_token = tokens_without_punct[-2]
        return true if last_token.pos == "AUX" && prev_token&.pos&.match?(/NOUN|PROPN|PRON/)

        false
      end

      def reconstruct_lines(text)
        lines = text.split("\n").map(&:strip).reject(&:empty?)
        with_progress(message: "Reconstructing [:bar]", total: lines.count) do |bar|
          bar.iterate(reconstructor(lines), lines.count).to_a.join
        end
      end

      # Reconstructs a sentence from multiple lines.
      #
      # An example:
      # テストの
      # 一行目の
      # 続きです。
      # 二行目です。
      #
      # Output:
      # テストの一行目の続きです。
      # 二行目です。
      def reconstructor(lines)
        Enumerator.new do |y|
          lines.each_with_index do |line, i|
            reconstructed = String.new
            reconstructed << line
            next_line = lines[i + 1]
            reconstructed << "\n" if should_break_after?(line, next_line)
            y.yield reconstructed
          end
        end
      end

      def should_break_after?(current, next_line)
        return true if next_line.nil? # 最終行
        return true if current.match?(/[。!！?？]$/) # 句点で終わる

        # 見出し・箇条書き判定（正規表現は適宜拡張）
        # 数字、(1)、第○ などを独立した行とみなす
        return true if next_line.match?(/^([0-9０-９]|[（(]?[0-9]|[第・■●○])/)

        # 現在の行が極端に短い（見出しの可能性）
        return true if current.length < MIN_CHAR_LEN_BREAK

        false
      end
    end
  end
end
