# frozen_string_literal: true

require "pragmatic_segmenter"

module Rokujo
  module Extractor
    # The base class of Extractors
    class Base
      attr_reader :file_path, :metadata

      def initialize(file_path, metadata = {})
        @file_path = file_path
        @metadata = metadata
      end

      def extract_sentences
        content = raw_text
        return [] if content.nil? || content.empty?

        normalized_text = reconstruct_lines(content)
        segment_text(normalized_text).map.with_index do |s, i|
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
      def reconstruct_lines(text)
        lines = text.split("\n").map(&:strip).reject(&:empty?)
        reconstructed = String.new
        lines.each_with_index do |line, i|
          reconstructed << line
          next_line = lines[i + 1]
          reconstructed << "\n" if should_break_after?(line, next_line)
        end
        reconstructed
      end

      def should_break_after?(current, next_line)
        return true if next_line.nil? # 最終行
        return true if current.match?(/[。!！?？]$/) # 句点で終わる

        # 見出し・箇条書き判定（正規表現は適宜拡張）
        # 数字、(1)、第○ などを独立した行とみなす
        return true if next_line.match?(/^([0-9０-９]|[（(]?[0-9]|[第・■●○])/)

        # 現在の行が極端に短い（見出しの可能性）
        return true if current.length < 10

        false
      end
    end
  end
end
