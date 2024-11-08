class HomeController < ApplicationController
  require 'rss'
  require 'open-uri'

  def index
    @rss_feed_items = fetch_rss_feed('https://deadline.com/rss')
  end

  private

  def fetch_rss_feed(url)
    items = []
    URI.open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        items << { title: item.title, link: item.link, description: item.description }
      end
    end
    items
  rescue => e
    Rails.logger.error "Error fetching RSS feed: #{e.message}"
    []
  end
end
