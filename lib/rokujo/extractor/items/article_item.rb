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
        attr_reader :opts, :json, :sources
        attr_accessor :acquired_time,
                      :author,
                      :body,
                      :description,
                      :kind,
                      :location,
                      :modified_time,
                      :published_time,
                      :sentences,
                      :site_name,
                      :title,
                      :url
        attr_writer :lang, :item_type, :character_count

        include Rokujo::Extractor::Concerns::Identifiable

        def initialize(opts = {})
          @opts = opts
          @sources = []
        end

        def sources=(sources)
          @sources = sources.map { |s| s.instance_of?(self.class) ? s : self.class.from_hash(s) }
        end

        def item_type
          self.class.to_s.split("::").last
        end

        # @return [Integer] Character length without space
        def character_count
          return 0 if sentences.nil? || sentences.empty?

          sentences.map { |element| element[:text] }.join.gsub(/\p{Space}/, "").size
        end

        # @return [String] Two-letter language code og the body
        def lang
          return nil if sentences.nil? || sentences.empty?

          @cld3 ||= CLD3::NNetLanguageIdentifier.new(0, 1000)
          text = sentences[0..10].map { |element| element[:text] }.join
          @lang = @cld3.find_language(text).language.to_s
        end

        # rubocop:disable Metrics/AbcSize
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
            sentences: sentences,
            site_name: site_name,
            sources: sources.map(&:to_h),
            title: title,
            url: url,
            uuid: uuid
          }
        end
        # rubocop:enable Metrics/AbcSize

        def uuid
          @uuid ||= uuid_v7
        end

        def self.from_hash(hash)
          article = new
          hash.each do |k, v|
            article.send("#{k}=", v)
          end
          article.location = hash["url"]
          article
        end

        def self.from_string(string)
          hash = JSON.parse(string, allow_control_characters: true)
          from_hash(hash)
        end
      end
    end
  end
end
