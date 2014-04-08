require 'nokogiri'
require 'open-uri'
require "net/http"

sitemap_base_url = 'http://fair-price.biz/sitemap/sitemap-index.xml'
base_xml = Nokogiri::XML(open(sitemap_base_url))
sitemap_urls = base_xml.xpath('//xmlns:loc').map{|el| el.children.first.inner_text}

def get_path url
  url.gsub('http://fair-price.biz/', '')
end

def get_default_url path
  'http://fair-price.biz/'+ path
end

def get_rails_url path
  'http://rails.checena.ru/' + path
end

def valid_url? check_url
  url = URI.parse(check_url)
  req = Net::HTTP.new(url.host, url.port)
  res = req.request_head(url.path)
  res.code.to_i == 200
end

bad_default_urls = bad_rails_urls = bad_only_rails_urls =[]
sitemap_urls.each do |sitemap_url|
  xml = Nokogiri::XML(open(sitemap_url))
  urls = xml.xpath('//xmlns:loc').map{|el| el.children.first.inner_text}
  urls.each do |url|
    path = get_path(url)

    default_url = get_default_url(path)
    default_valid_url = valid_url?(default_url)
    bad_default_urls << default_url unless default_valid_url

    rails_url = get_rails_url(path)
    rails_valid_url = valid_url?(rails_url)
    bad_rails_urls << rails_url unless rails_valid_url

    if default_valid_url and !rails_valid_url
      bad_only_rails_urls << rails_url
    end
  end
end

File.open('reports/bad_default_urls.txt', 'w') { |file| bad_default_urls.each{|u| file.write("#{u}\n")}}
File.open('reports/bad_rails_urls.txt', 'w') { |file| bad_default_urls.each{|u| file.write("#{u}\n")}}
File.open('reports/bad_only_rails_urls.txt', 'w') { |file| bad_only_rails_urls.each{|u| file.write("#{u}\n")}}