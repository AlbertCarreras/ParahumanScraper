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
    title = page.xpath("//h1[contains(@class, 'entry-title')]").text
    main_body = page.xpath("//div[contains(@class, 'entry-content')]").text
    title + main_body + "\n"
  end
  story_sections
end

def parse_single_page(page)
  header = page.xpath("//h1[contains(@class, 'entry-title')]")
  parsed_page = page.xpath("//div[contains(@class, 'entry-content')]").text
  test_parse = page.xpath("//h1")
  # title_and_story = header.text + parsed_page
  # title_and_story.gsub!("\n", "\n\n")
  # file = File.open("ward-test.txt", "w")
  # file.write(title_and_story)
  # file.close
end




scraped_page = web_scraper(content_page_url)
story_page_links = get_table_of_contents_links(scraped_page)
story_pages = get_story_pages(story_page_links)
story_sections = get_story_content(story_pages)

# scraped_chapter = web_scraper("https://www.parahumans.net/2018/05/15/torch-7-1/")
# story_sections = parse_single_page(scraped_chapter)

file = File.open("ward.txt", "w")

story_sections.each do |section|
  section.gsub!("\n", "\n\n")
  file.write(section)
end

file.close
