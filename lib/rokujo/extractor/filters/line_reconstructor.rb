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
      class LineReconstructor < Base
        # A line is considered as a sentence when the line length is less than
        # this value. Such lines are likely to be a title or an item name.
        MIN_CHAR_LEN_BREAK = 10

        # Reconstructs the sentences in the string.
        #
        # @param raw_text [String] A string of texts.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        # @return [String]
        #
        def call(input, widget_enable: true)
          self.widget_enable = widget_enable
          # create an array so that we can tell how many steps we are going to
          # proceed to the progress bar.
          items = input.is_a?(String) ? input.lines : input
          with_progress(total: items.size) do |bar|
            reconstruct(items) { bar&.advance(1) }
          end
        end

        private

        def reconstruct(items)
          buffer = []
          items.each_with_index.with_object([]) do |(line, i), result|
            buffer << line.strip
            yield if block_given?

            if should_break_after?(line, items[i + 1])
              result << buffer.join
              buffer.clear
            end
          end
        end

        # Returns Array of line, striped, empty lines removed.
        def strip_with_newline(raw_text)
          raw_text.lines.map(&:strip).reject(&:empty?)
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
