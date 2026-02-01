# frozen_string_literal: true

require "cld3"
require "pathname"
require "time"
require "uri"

module Rokujo
  module Extractor
    module Items
      # ArticleItem
      class ArticleItem
        attr_reader :opts
        attr_accessor :acquired_time,
                      :author,
                      :body,
                      :description,
                      :kind,
                      :location,
                      :modified_time,
                      :published_time,
                      :site_name,
                      :sources,
                      :title,
                      :url,
                      :uuid

        def initialize(location, opts = {})
          @location = Pathname.new(location)
          @opts = opts
        end

        def item_type
          self.class.to_s.split("::").last
        end

        # @return [Integer] Character length without space
        def character_count
          return @character_count if @character_count

          @character_count ||= body.map { |element| element[:text] }.join.gsub(/\p{Space}/, "").size
        end

        # @return [String] Two-letter language code og the body
        def lang
          return @lang if @lang

          @cld3 ||= CLD3::NNetLanguageIdentifier.new(0, 1000)
          text = body[0..10].map { |element| element[:text] }.join
          @lang = @cld3.find_language(text).language.to_s
        end

        def to_h
          return @hash if @hash

          @to_h ||= {
            acquired_time: acquired_time,
            author: author,
            body: body,
            character_count: character_count,
            description: description,
            item_type: item_type,
            kind: kind,
            lang: lang,
            modified_time: modified_time,
            published_time: published_time,
            site_name: site_name,
            sources: [],
            title: title,
            url: url,
            uuid: uuid
          }
        end
      end
    end
  end
end
