# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Formatters::CSV do
  let(:formatter) { described_class.new }
  let(:sentences) do
    %w[foo bar buz].map do |e|
      {
        text: e,
        meta: {
          line_number: 1,
          uuid: "uuid"
        }
      }
    end
  end

  describe "#call" do
    it "returns String" do
      expect(formatter.call(sentences)).to be_a String
    end

    it "returns CSV-parsable String" do
      string = formatter.call(sentences)

      expect { CSV.parse(string) }.not_to raise_error
    end

    specify "each row has a sentence in the 1st column" do
      string = formatter.call(sentences)
      rows = CSV.parse(string)

      expect(rows.map(&:first)).to match_array %w[foo bar buz]
    end

    specify "each row has a line number in the 2nd column" do
      string = formatter.call(sentences)
      rows = CSV.parse(string, converters: :integer)

      expect(rows.map { |r| r[1] }).to contain_exactly(1, 1, 1)
    end

    specify "the line numbers are not quoted" do
      lines = formatter.call(sentences).lines

      expect(lines).to all(match(/\A(?:foo|bar|buz),\d+,/))
    end

    specify "each row has a sentence in the 3rd column" do
      string = formatter.call(sentences)
      rows = CSV.parse(string)

      expect(rows.map { |r| r[2] }).to match_array %w[uuid uuid uuid]
    end
  end
end
