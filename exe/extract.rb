#!/usr/bin/env ruby
# frozen_string_literal: true

require "rokujo/extractor/parsers/article"

File.readlines(ARGV.shift).each do |line|
  parser = Rokujo::Extractor::Parsers::Article.new(line)
  parser.extract_sentences
  puts parser.item.to_h.to_json
end
