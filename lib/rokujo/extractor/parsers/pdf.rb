# frozen_string_literal: true

require "shellwords"
require "open3"
require_relative "base"
require_relative "../items/pdf_item"

module Rokujo
  module Extractor
    module Parsers
      # Extracts PDF files.
      class PDF < Base
        def initialize(location, opts = {})
          super
        end

        def item
          @item ||= Rokujo::Extractor::Items::PdfItem.new(location)
        end

        def dump
          return @dump if @dump

          # call pdftotext CLI instead of require "poppler" because poppler
          # gem, or possibly its dependencies, causes double-free somewhere
          # while spacy is running.
          #
          # the output of pdftotext is easier to reliably parse than pdf-reader.
          stdout, stderr, status = Open3.capture3("pdftotext", location.to_s, "-")
          raise "pdftotext error: #{stderr} (file: #{location})" unless status.success?

          @dump = stdout
        end

        def raw_text
          return @raw_text if @raw_text

          with_spinner(file: location.basename) do
            lines = dump.lines
            filtered_lines = lines.select.with_index do |line, index|
              previous_line = lines[index - 1]
              should_be_kept?(line, previous_line)
            end
            @raw_text = filtered_lines.join
          end
        end

        private

        def should_be_kept?(line, previous_line)
          return false if line =~ /^\s*\R$/
          # if the current line is short and the previous line is short as
          # well, the current line is probably not a part of the previous
          # sentence.
          return false if line.length < min_char_per_line && previous_line.length < min_char_per_line

          true
        end

        def char_per_line
          @char_per_line ||= median(dump.lines.select { |e| e.size > 32 }.map(&:length))
        end

        def min_char_per_line
          @min_char_per_line ||= (char_per_line * 0.5).to_i
        end

        def median(array)
          sorted = array.sort
          size = array.size
          center = size / 2
          size.even? ? (sorted[center] + sorted[center - 1]) / 2.0 : sorted[center]
        end
      end
    end
  end
end
