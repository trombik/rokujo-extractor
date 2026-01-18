# frozen_string_literal: true

module Rokujo
  module Extractor
    module Items
      MetadataItem = Data.define(:type, :content) do
        #
        # Initializes a new MetadataItem, a generic metadata item for any
        # data.
        #
        # @param type [Object] the type of the metadata
        # @param content [Object] the content of the metadata
        # @return [MetadataItem] a new MetadataItem instance
        def initialize(type:, content:)
          super(type: type, content: content.freeze)
        end

        # Creates a new MetadataItem from the given input.
        #
        # @param input [MetadataItem, Hash] the input to convert to a MetadataItem
        # @return [MetadataItem] a new MetadataItem instance
        # @raise [TypeError] if the input cannot be converted to a MetadataItem
        def self.from(input)
          case input
          when self then input
          when Hash then new(**input.transform_keys(&:to_sym))
          else raise TypeError, "Cannot convert #{input.class} to MetadataItem\n" \
                                "The input must be a Hash or MetadataItem.\n" \
                                "#{input.inspect}"
          end
        end
      end

      LineItem = Data.define(:text, :number) do
        #
        # Initializes a new LineItem. A LineItem is a raw line. `text` might
        # or might not be a sentence, i.e., it can be a part of a sentence, or
        # simply a title of an item (such as headings). This item is used
        # before lines of texts are segmented.
        #
        # @param text [String] the text of the line without newlines.
        # @param number [Integer, nil] the positive line number in Integer.
        # @return [LineItem] a new LineItem instance
        # @raise [ArgumentError] if the text contains a newline or the number is invalid
        def initialize(text:, number: nil)
          validate!(text, number)
          super
        end

        private

        def validate!(text, number)
          validate_text!(text)
          validate_number!(number)
        end

        def validate_text!(text)
          return unless text.to_s.include?("\n")

          raise ArgumentError, "text must not contain newline: `#{text.inspect}`"
        end

        def validate_number!(number)
          return if number.nil?

          unless number.is_a?(Integer)
            raise ArgumentError, "number must be an Integer or nil, " \
                                 "not `#{number.class}`:\n#{number.inspect}\n"
          end
          raise ArgumentError, "number must be positive: #{number.inspect}" if number.negative?
        end
      end

      SentenceItem = Data.define(:text, :metadata) do
        #
        # Initializes a new SentenceItem. `text` is a segmented sentence.
        #
        # @param text [String] the text of the sentence
        # @param metadata [MetadataItem, Hash] the metadata of the sentence
        # @return [SentenceItem] a new SentenceItem instance
        def initialize(text:, metadata:)
          super(text: text, metadata: MetadataItem.from(metadata))
        end
      end
    end
  end
end
