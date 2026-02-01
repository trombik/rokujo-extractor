#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require "ruby-spacy"
require "rokujo/extractor/parsers/base"

texts = File.read("spec/fixture/1000.txt").lines(chomp: true)
model = Spacy::Language.new("ja_ginza")

configs = [
  { label: "Parallel (ncpu: 1)", ncpu: 1, chunk: 50 },
  { label: "Parallel (ncpu: 2)", ncpu: 2, chunk: 50 },
  { label: "Parallel (ncpu: 3)", ncpu: 3, chunk: 50 },
  { label: "Parallel (ncpu: 4)", ncpu: 4, chunk: 50 },
  { label: "Parallel (ncpu: 4, chunk: 200)", ncpu: 4, chunk: 200 }
]

puts "=== Performance Comparison ==="
Benchmark.bm(30) do |x|
  configs.each do |config|
    GC.start
    x.report(config[:label]) do
      rejector = Rokujo::Extractor::Filters::VerblessRejector.new(model: model)
      rejector.call(texts,
                    widget_enable: false,
                    ncpu: config[:ncpu],
                    chunk_size: config[:chunk])
    end
  end
end
