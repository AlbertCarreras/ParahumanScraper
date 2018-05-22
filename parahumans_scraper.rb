require 'httparty'
require 'pry'
require 'nokogiri'
require 'open-uri'

def run
  scraped_page = web_scraper(content_page_url)
  story_page_links = get_table_of_contents_links(scraped_page)
  story_pages = get_story_pages(story_page_links)
  story_sections = get_story_content(story_pages)
  story_sections = format_pages(story_sections)
  write_story_to_doc(story_sections, get_filename)
end

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
  content_section = scraped_page.xpath("//div[contains(@class, 'entry-content')]")
  link_items = content_section.xpath(".//a")
  link_list = link_items.map {|node| node["href"]}
end

def get_latest_page(content_links)
  latest_link = content_links.last
  if latest_link.include?("http:")
    web_scraper(latest_link.gsub("http", "https"))
  else
    web_scraper(latest_link)
  end
end

def get_title_and_body(page)
  title = page.xpath("//h1[contains(@class, 'entry-title')]").text
  main_body = page.xpath("//div[contains(@class, 'entry-content')]").text
  title + main_body + "\n"
end

def get_story_content(story_pages)
  story_sections = story_pages.map do |page|
    get_title_and_body(page)
  end
  story_sections
end

def get_latest_chapter
  chapter_page_links = get_table_of_contents_links(web_scraper(content_page_url))
  latest_chapter_page = get_latest_page(chapter_page_links)
  latest_chapter_text = get_title_and_body(latest_chapter_page)
  formatted_chapter = format_pages([latest_chapter_text]).join("")
  filename = get_filename
  append_to_doc(formatted_chapter, filename)
end

def get_filename
  puts "Please enter a name for the file to be written: "
  file_name = gets.chomp
end

def write_story_to_doc(story_sections, filename)
  file = File.open("#{filename}.txt", "w")
  story_sections.each do |section|
    file.write(section)
  end
  file.close
end

def append_to_doc(chapter, filename)
  file = File.open("#{filename}.txt", "a")
  file.write(chapter)
  file.close
end

def format_pages(story_content)
  story_content.each do |page|
    page.gsub!("Previous Chapter", "")
    page.gsub!("Next Chapter", "")
    page.gsub!("Last Chapter", "")
    page.gsub!("\n", "\n\n")
  end
end

puts Dir.pwd
get_latest_chapter
