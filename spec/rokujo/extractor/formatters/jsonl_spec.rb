# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Formatters::JSONL do
  let(:formatter) { described_class.new }
  let(:sentences) { %w[foo bar buz].map { |e| { content: e } } }

  RSpec::Matchers.define :be_a_json_hash do
    match do |actual|
      parsed = JSON.parse(actual)
      parsed.is_a? Hash
    rescue JSON::ParserError
      false
    end

    failure_message do |actual|
      "expected the actual value is a valid JSON hash but it wasn't.\n" \
        "Actual: #{actual.inspect}"
    end

    failure_message_when_negated do |actual|
      "expected the actual value is a valid JSON hash but it was.\n" \
        "Actual: #{actual.inspectl}"
    end
  end

  describe "#call" do
    it "returns String" do
      expect(formatter.call(sentences)).to be_a String
    end

    it "returns lines of JSON string" do
      results = formatter.call(sentences).split("\n")
      expect(results).to all be_a_json_hash
    end
  end
end
