class HomeController < ApplicationController
  require 'rss'
  require 'open-uri'

  def index
    @rss_feed_items = []
    
    # Fetch Puck feed
    puck_url = 'https://puck.news/category/hollywood/feed/'
    @rss_feed_items += fetch_rss_feed(puck_url, 'Puck')

    # Fetch Deadline feed
    deadline_url = 'https://deadline.com/rss'
    @rss_feed_items += fetch_rss_feed(deadline_url, 'Deadline')

    # Fetch Deadline Box Office feed
    deadline_box_office_url = 'https://deadline.com/v/box-office/feed'
    @rss_feed_items += fetch_rss_feed(deadline_box_office_url, 'Deadline Box Office')
  end

  private

  def fetch_rss_feed(url, source)
    items = []
    URI.open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        items << { 
          title: item.title,
          link: item.link,
          description: item.description,
          pubDate: item.pubDate,
          categories: item.categories.map(&:content),
          source: source  # Set the source here
        }
      end
    end
    items
  rescue => e
    Rails.logger.error "Error fetching RSS feed from #{source}: #{e.message}"
    []
  end
end
