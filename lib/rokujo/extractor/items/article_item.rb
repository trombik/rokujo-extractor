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
        attr_reader :opts, :json
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
        attr_writer :lang, :item_type, :character_count

        include Rokujo::Extractor::Concerns::Identifiable

        def initialize(opts = {})
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

        def uuid
          @uuid ||= uuid_v7
        end

        def self.from_string(string)
          article = new
          hash = JSON.parse(string, allow_control_characters: true)
          hash.each do |k, v|
            article.send("#{k}=", v)
          end
          article.location = hash["url"]
          article
        end
      end
    end
  end
end
