# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to reconstruct sentences from a raw text string.
      #
      # Input:
      #
      # これはテストの一行目の
      # 続きです。
      # タイトル
      # これは一行になった二行目です。
      # これは最後の三行目で、
      # 二行に分かれています。
      #
      # Output:
      #
      # これはテストの一行目の続きです。
      # タイトル
      # これは一行になった二行目です。
      # これは最後の三行目で、二行に分かれています。
      #
      class LineReconstructor
        # A line is considered as a sentence when the line length is less than
        # this value. Such lines are likely to be a title or an item name.
        MIN_CHAR_LEN_BREAK = 10

        def initialize; end

        # Reconstructs the sentences in the string.
        #
        # @param raw_text [String] A string of texts.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        # @return [String]
        def call(raw_text, bar = nil)
          reconstructed = String.new
          # create an array so that we can tell how many steps we are going to
          # proceed to the progress bar.
          lines = strip_with_newline(raw_text)

          # set total size of the operations
          bar&.configure { |config| config.total = lines.count }

          lines.each_with_index do |line, i|
            reconstructed << line
            reconstructed << "\n" if should_break_after?(line, lines[i + 1])
            bar&.advance
          end
          bar&.finish
          reconstructed
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end

        private

        # Returns Array of line, striped, empty lines removed.
        def strip_with_newline(raw_text)
          raw_text.split("\n").map(&:strip).reject(&:empty?)
        end

        def base_class_name
          self.class.name.split("::").last
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
end
