require 'httparty'
require 'pry'
require 'nokogiri'
require 'open-uri'

def web_scraper(url)
  Nokogiri::HTML(open(url))
end

def content_page_url
  'https://www.parahumans.net/table-of-contents/'
end

def get_story_pages(link_list)
  link_list.map do |link|
    if link.include?("http:")
      web_scraper(link.gsub("http", "https"))
    else
      web_scraper(link)
    end
  end
end

def get_table_of_contents_links(scraped_page)
  link_items = scraped_page.xpath("//div[contains(@class, 'entry-content')]/p[contains(@style, 'padding-left')]/a")
  link_list = link_items.map {|node| node["href"]}
end

def get_story_content(story_pages)
  story_sections = story_pages.map do |page|
    page.xpath("//div[contains(@class, 'entry-content')]")
  end
  story_sections.map {|node| node.text}
end

# XPATH //div[contains(@class, 'entry-content')]/p[contains(@style, 'padding-left')]/a

scraped_page = web_scraper(content_page_url)
story_page_links = get_table_of_contents_links(scraped_page)
story_pages = get_story_pages(story_page_links)
story_sections = get_story_content(story_pages)

file = File.open("ward.txt", "w")

story_sections.each do |section|
  file.write(section)
end

file.close
binding.pry
