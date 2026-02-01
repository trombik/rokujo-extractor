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
                      :url

        def initialize(location, opts = {})
          @location = Pathname.new(location)
          @opts = opts
        end

        def item_type
          self.class.to_s.split("::").last
        end

        # @return [Integer] Character length without space
        def character_count
          body.gsub(/\p{Space}/, "").size
        end

        # @return [String] Two-letter language code og the body
        def lang
          cld3 = CLD3::NNetLanguageIdentifier.new(0, 1000)
          cld3.find_language(body[0, 200]).language.to_s
        end

        def to_h
          {
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
            url: url
          }
        end
      end
    end
  end
end
