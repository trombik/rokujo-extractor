# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # Normalize characters.
      #
      # This filter expects string, not an array of strings.
      class Normalizer < Base
        # Enclosed Alphanumerics
        TR_ENCLOSED_ALPHANUMERICS = ["①-⑨❶-❾ⓐ-ⓩ", "1-91-9a-z"].freeze
        MAP_ENCLOSED_ALPHANUMERICS = {
          "⑩" => "10", "⑪" => "11", "⑫" => "12", "⑬" => "13", "⑭" => "14",
          "⑮" => "15", "⑯" => "16", "⑰" => "17", "⑱" => "18", "⑲" => "19", "⑳" => "20",
          "❿" => "10",

          # (1)-(20)
          "⑴" => "(1)", "⑵" => "(2)", "⑶" => "(3)", "⑷" => "(4)", "⑸" => "(5)",
          "⑹" => "(6)", "⑺" => "(7)", "⑻" => "(8)", "⑼" => "(9)", "⑽" => "(10)",
          "⑾" => "(11)", "⑿" => "(12)", "⒀" => "(13)", "⒁" => "(14)", "⒂" => "(15)",
          "⒃" => "(16)", "⒄" => "(17)", "⒅" => "(18)", "⒆" => "(19)", "⒇" => "(20)",

          # 1. - 20.
          "⒈" => "1.", "⒉" => "2.", "⒊" => "3.", "⒋" => "4.", "⒌" => "5.",
          "⒍" => "6.", "⒎" => "7.", "⒏" => "8.", "⒐" => "9.", "⒑" => "10.",
          "⒒" => "11.", "⒓" => "12.", "⒔" => "13.", "⒕" => "14.", "⒖" => "15.",
          "⒗" => "16.", "⒘" => "17.", "⒙" => "18.", "⒚" => "19.", "⒛" => "20."

        }.freeze

        # rubocop:disable Metrics/MethodLength
        def call(raw_text, widget_enable: true)
          self.widget_enable = widget_enable
          # create an array so that we can tell how many steps we are going to
          # proceed to the progress bar.
          lines = raw_text.lines
          with_progress(total: lines.count * 512) do |bar|
            normalized = lines.map do |line|
              result = normalize(line)
              bar&.advance(512)
              result
            end
            bar.finish
            normalized.join
          end
        end
        # rubocop:enable Metrics/MethodLength

        def normalize(text)
          text.tr!(TR_ENCLOSED_ALPHANUMERICS.first, TR_ENCLOSED_ALPHANUMERICS.last)
          MAP_ENCLOSED_ALPHANUMERICS.each do |from, to|
            text.gsub!(from, to)
          end
          text.gsub(/\p{Extended_Pictographic}/, "")
              .unicode_normalize(:nfkc)
              # the following normalizations must be done after unicode_normalize.
              # normalize tilde and wave-dashes to 〜.
              .tr("~～〜", "〜〜〜")
              # smart quotes
              .tr("“”〝〟", '""""')
              .tr("‘’`´", "''''")
              # braces
              .tr("【】［］〔〕《》〈〉", "[][][][][]")
        end
      end
    end
  end
end
